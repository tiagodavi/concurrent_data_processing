defmodule PageProducer do
  use GenStage

  require Logger

  def start_link(args \\ []) do
    GenStage.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(args) do
    Logger.info("PageProducer: INIT")

    {:producer, args, buffer_size: 1}
  end

  @doc """
  PageProducer.scrape(Utils.pages())
  """
  def scrape(pages) when is_list(pages) do
    GenStage.cast(__MODULE__, {:pages, pages})
  end

  def handle_cast({:pages, pages}, state) do
    {:noreply, pages, state}
  end

  def handle_demand(demand, state) do
    Logger.info("PageProducer: received demand for #{demand} pages")

    events = []

    {:noreply, events, state}
  end
end
