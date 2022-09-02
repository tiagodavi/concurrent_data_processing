defmodule PageConsumer do
  # use GenStage

  require Logger

  def start_link(event) do
    Logger.info("PageConsumer received #{inspect(self())} #{event}")

    Task.start_link(fn ->
      Scrapper.work()
    end)
  end

  def child_spec(args) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, args},
      restart: :transient
    }
  end

  # def start_link(args \\ []) do
  #   GenStage.start_link(__MODULE__, args)
  # end

  # def init(args) do
  #   Logger.info("PageConsumer: INIT")

  #   subs_opts = [{PageProducer, min_demand: 0, max_demand: 1}]

  #   {:consumer, args, subscribe_to: subs_opts}
  # end

  # def handle_events(events, _from, state) do
  #   Logger.info("PageConsumer: received #{inspect(events)}")

  #   Enum.each(events, fn _page ->
  #     Scrapper.work()
  #   end)

  #   {:noreply, [], state}
  # end
end
