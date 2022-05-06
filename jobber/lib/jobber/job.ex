defmodule Jobber.Job do
  use GenServer, restart: :transient

  require Logger

  defstruct [:id, :work, :max_retries, retries: 0, status: :new]

  @five_secs 5_000

  def start_link(args) do
    args =
      if Keyword.has_key?(args, :id) do
        args
      else
        Keyword.put(args, :id, random_job_id())
      end

    id = Keyword.fetch!(args, :id)
    type = Keyword.fetch!(args, :type)

    GenServer.start_link(__MODULE__, args, name: via(id, type))
  end

  @impl true
  def init(args) do
    work = Keyword.fetch!(args, :work)
    id = Keyword.fetch!(args, :id)
    max_retries = Keyword.get(args, :max_retries, 3)
    state = %__MODULE__{id: id, work: work, max_retries: max_retries}

    {:ok, state, {:continue, :run}}
  end

  @impl true
  def handle_continue(:run, state) do
    new_state = handle_job_result(state.work.(), state)

    if new_state.status == :errored do
      Process.send_after(self(), :retry, @five_secs)
      {:noreply, new_state}
    else
      Logger.info("Job exiting #{state.id}")
      {:stop, :normal, new_state}
    end
  end

  @impl true
  def handle_info(:retry, state) do
    {:noreply, state, {:continue, :run}}
  end

  defp handle_job_result({:ok, _data}, state) do
    Logger.info("Job completed #{state.id}")
    %__MODULE__{state | status: :done}
  end

  defp handle_job_result({:error, _reason}, %{status: :new} = state) do
    Logger.warn("Job errored #{state.id}")
    %__MODULE__{state | status: :errored}
  end

  defp handle_job_result({:error, _reason}, %{status: :errored} = state) do
    Logger.warn("Job retry failed #{state.id}")
    new_state = %__MODULE__{state | retries: state.retries + 1}

    if new_state.retries == state.max_retries do
      %__MODULE__{new_state | status: :failed}
    else
      new_state
    end
  end

  defp handle_job_result(_, _state), do: raise(ArgumentError, "Invalid job return!")

  defp random_job_id do
    Base.url_encode64(:crypto.strong_rand_bytes(5), padding: false)
  end

  defp via(key, value) do
    {:via, Registry, {Jobber.JobRegistry, key, value}}
  end
end
