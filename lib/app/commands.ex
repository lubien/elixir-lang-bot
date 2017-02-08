defmodule App.Commands do
  use App.Router
  use App.Commander

  @bot_name Application.get_env(:app, :bot_name)

  command "help" do
    message = """
    <b>Showing Help</b>

    <b>Commands</b>
    <i>For normal commands, just send me a message.</i>

    /help

    <b>Inline Commands</b>
    <i>For inline commands, type "@#{@bot_name}" then the command.</i>

    <code>/hex [package_name]</code>

    <b>Channels</b>

    @elixir_forum - <i>Elixir forum</i>
    @rElixir - <i>Elixir subreddit</i>
    @elixirstatus - <i>Elixirstatus</i>
    """

    {:ok, _} = send_message message, parse_mode: "html"
  end

  inline_query_command "hex" do
    "/hex" <> query = update.inline_query.query
                      |> String.trim

    {:ok, packages} = App.Hex.packages query

    results = packages
    |> Enum.take(20)
    |> Enum.map(&App.Hex.package_to_inline_query_result/1)

    case answer_inline_query(results) do
      :ok -> nil
      {:error, %Model.Error{reason: reason}} ->
        Logger.log :error, "Errored with query '#{query}'"
        Logger.log :error, "Reason: #{reason}"
    end
  end

  inline_query do
    answer_inline_query []

    ExStatsD.increment("inline_query.unmatched")
  end

  message do
    send_message """
    Sorry, I didn't undestand.
    Try running the /help command.
    """

    ExStatsD.increment("message.unmatched")
  end
end
