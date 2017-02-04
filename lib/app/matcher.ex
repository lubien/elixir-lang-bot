defmodule App.Matcher do
  use GenServer
  alias App.{Commands, Telegram}

  # Server

  def start_link do
    GenServer.start_link __MODULE__, :ok, name: __MODULE__
  end

  def init(:ok) do
    {:ok, 0}
  end

  def handle_cast(message, state) do
    message
    |> Telegram.get_chat_id
    |> ExStatsD.set("users")

    Commands.match_message message

    {:noreply, state}
  end

  # Client

  def match(message) do
    GenServer.cast __MODULE__, message
  end
end
