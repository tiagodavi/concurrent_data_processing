defmodule Scrapper do
  @moduledoc """
  Documentation for `Scrapper`.
  """

  def online?(_url) do
    work()

    Enum.random([false, true, true])
  end

  def work do
    1..5
    |> Enum.random()
    |> :timer.seconds()
    |> Process.sleep()
  end
end
