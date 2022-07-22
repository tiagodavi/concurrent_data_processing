defmodule Scrapper do
  @moduledoc """
  Documentation for `Scrapper`.
  """

  def work do
    1..5
    |> Enum.random()
    |> :timer.seconds()
    |> Process.sleep()
  end
end
