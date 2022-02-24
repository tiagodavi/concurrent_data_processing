defmodule SendServer do
  use GenServer

  @five_secs 5_000

  @impl GenServer
  def init(args) do
    IO.puts("Received arguments #{inspect(args)}")

    max_retries = Keyword.get(args, :max_retries, 5)

    state = %{emails: [], max_retries: max_retries}

    Process.send_after(self(), :retry, @five_secs)

    {:ok, state}
  end

  @impl GenServer
  def handle_cast({:send, email}, state) do
    status = try_to_send_email(email)

    emails = state.emails ++ [%{email: email, status: status, retries: 0}]

    {:noreply, %{state | emails: emails}}
  end

  @impl GenServer
  def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end

  @impl GenServer
  def handle_info(:retry, state) do
    {failed, done} =
      Enum.split_with(state.emails, fn item ->
        item.status == :failed && item.retries < state.max_retries
      end)

    retried =
      Enum.map(failed, fn item ->
        IO.puts("Retrying to send email #{item.email}...")
        new_status = try_to_send_email(item.email)
        %{email: item.email, status: new_status, retries: item.retries + 1}
      end)

    Process.send_after(self(), :retry, @five_secs)

    {:noreply, %{state | emails: done ++ retried}}
  end

  @impl GenServer
  def terminate(reason, _state) do
    IO.puts("Terminating with reason #{reason}")
  end

  defp try_to_send_email(email) do
    email
    |> Sender.send_email()
    |> case do
      {:ok, _email} -> :sent
      {:error, _email} -> :failed
    end
  end
end
