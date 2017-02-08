defmodule App.FeedsPoller do
  use GenServer
  require Logger
  alias App.{Feed, Stats}

  @feeds [
    Feed.ElixirStatus,
    Feed.PCTGuama,
    Feed.RElixir,
    Feed.ElixirForum
  ]
  @feed_count @feeds |> Enum.count

  # 30 minutes poll intervals
  @poll_interval 30 * 60 * 1000

  def start_link do
    Logger.info "Started polling feeds"
    GenServer.start_link __MODULE__, :ok, name: __MODULE__
  end

  def init(:ok) do
    init_feeds()
    tick_feeds()
    {:ok, 0}
  end

  def handle_cast(:update, 0) do
    tick_feeds()
    {:noreply, 0}
  end

  def handle_cast(:sleep, 0) do
    {:noreply, 0, @poll_interval}
  end

  def handle_info(:timeout, _) do
    trigger_update()
    {:noreply, 0}
  end

  def handle_info({:DOWN, _ref, :process, _pid, :normal}, finished_tasks) do
    {:noreply, finished_tasks}
  end

  def handle_info({_ref, {:error, {feed, reason}}}, finished_tasks) do
    Logger.error "Feed #{feed} errored with #{reason}"
    Stats.event "Feed Error", "Feed #{feed} errored with #{reason}", %{alert_type: "error"}
    update_counter finished_tasks
  end

  def handle_info({_ref, :ok}, finished_tasks) do
    update_counter finished_tasks
  end

  def handle_info(foo, state) do
    IO.inspect {"foo", foo, state}
    {:noreply, state}
  end

  # Helpers

  defp update_counter(@feed_count - 1) do
    trigger_sleep()
    {:noreply, 0}
  end
  defp update_counter(counter) do
    {:noreply, counter + 1}
  end

  defp trigger_update do
    GenServer.cast __MODULE__, :update
  end

  defp trigger_sleep do
    GenServer.cast __MODULE__, :sleep
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
      Task.async fn ->
        try do
          apply feed, :tick, []
        rescue
          e ->
            case e do
              %{message: message} ->
                {:error, {feed, message}}

              %{reason: reason} ->
                {:error, {feed, reason}}
            end
        else
          _ ->
            :ok
        end
      end
    end)
    0
  end
end
