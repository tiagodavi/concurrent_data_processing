defmodule PageConsumer do
  use GenStage

  require Logger

  def start_link(args \\ []) do
    GenStage.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(args) do
    Logger.info("PageConsumer: INIT")

    {:consumer, args, subscribe_to: [PageProducer]}
  end

  def handle_events(events, _from, state) do
    Logger.info("PageConsumer: received #{inspect(events)}")

    Enum.each(events, fn _page ->
      Scrapper.work()
    end)

    {:noreply, [], state}
  end
end
