defmodule App.ElixirStatusPoller do
  use GenServer
  require Logger
  alias App.ElixirStatusChannel

  # 30 minutes poll intervals
  @poll_interval 30 * 60 * 1000

  # Server

  def start_link do
    Logger.log :info, "Started polling @elixirstatus"
    GenServer.start_link __MODULE__, :ok, name: __MODULE__
  end

  def init(:ok) do
    ElixirStatusChannel.load_stash
    update
    {:ok, 0}
  end

  def handle_cast(:update, state) do
    ElixirStatusChannel.update
    {:noreply, state, @poll_interval}
  end

  def handle_info(:timeout, state) do
    update
    {:noreply, state}
  end

  # Client

  def update do
    GenServer.cast __MODULE__, :update
  end
end
