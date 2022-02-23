defmodule SendServer do
  use GenServer

  @impl GenServer
  def init(args) do
    IO.puts("Received arguments #{inspect(args)}")

    max_retries = Keyword.get(args, :max_retries, 5)

    state = %{emails: [], max_retries: max_retries}

    {:ok, state}
  end

  @impl GenServer
  def handle_cast({:send, email}, state) do
    status =
      email
      |> Sender.send_email()
      |> case do
        {:ok, _email} -> :sent
        {:error, _email} -> :failed
      end

    emails = state.emails ++ [%{email: email, status: status, retries: 0}]

    {:noreply, %{state | emails: emails}}
  end

  @impl GenServer
  def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end
end
