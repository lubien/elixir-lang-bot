defmodule App.FeedsPoller do
  use GenServer
  require Logger
  alias App.Feed

  @feeds [
    Feed.ElixirStatus,
    Feed.PCTGuama,
    Feed.RElixir
  ]

  # 30 minutes poll intervals
  @poll_interval 30 * 60 * 1000

  def start_link do
    Logger.info "Started polling feeds"
    GenServer.start_link __MODULE__, :ok, name: __MODULE__
  end

  def init(:ok) do
    init_feeds()
    trigger_update()
    {:ok, 0}
  end

  def handle_cast(:update, _) do
    tick_feeds()
    {:noreply, 0, @poll_interval}
  end

  def handle_info(:timeout, _) do
    trigger_update()
    {:noreply, 0}
  end

  # Ignore task info
  def handle_info(_, _) do
    {:noreply, 0}
  end

  # Helpers

  defp trigger_update do
    GenServer.cast __MODULE__, :update
  end

  defp apply_to_feeds(function, args \\ []) do
    @feeds
    |> Enum.map(fn feed ->
      apply feed, function, args
    end)
  end

  defp init_feeds do
    @feeds
    |> Enum.map(fn feed ->
      apply feed, :init, []
    end)
  end

  defp tick_feeds do
    Logger.info "Triggered tick to feeds"

    @feeds
    |> Enum.map(fn feed ->
      Task.async fn -> apply feed, :tick, [] end
    end)
  end
end
