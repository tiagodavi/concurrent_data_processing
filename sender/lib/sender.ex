defmodule Sender do
  @moduledoc """
  Documentation for `Sender`.
  """

  # def send_email("konnichiwa@world.com" = email) do
  #   Process.sleep(3_000)
  #   raise "Boommm #{email}"
  # end

  def send_email("konnichiwa@world.com"), do: {:error, "konnichiwa@world.com"}

  def send_email(email) do
    Process.sleep(3_000)
    IO.puts("Email to #{email} sent")
    {:ok, email}
  end

  # def notify_all(emails) do
  #   emails
  #   |> Enum.map(&Task.async(fn -> send_email(&1) end))
  #   |> Enum.map(&Task.await/1)
  # end

  def notify_all(emails) do
    Sender.EmailTaskSupervisor
    |> Task.Supervisor.async_stream_nolink(emails, &send_email/1, ordered: false)
    |> Enum.to_list()
  end

  def build_emails do
    ["hello@world.com", "hola@world.com", "nihao@world.com", "konnichiwa@world.com"]
  end
end
