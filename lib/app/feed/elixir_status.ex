defmodule App.Feed.ElixirStatus do
  @behaviour App.Feed
  require Logger
  alias App.Persistor

  @feed_id "elixirstatus"
  @channel Application.get_env(:app, :elixirstatus_channel)

  # Public API

  def init do
    Persistor.load_stash @feed_id
  end

  def tick do
    get_feed()
    |> parse_feed
    |> convert_feed_dates
    |> filter_posted
    |> send_to_channel
  end

  # Private API

  defp get_feed do
    {:ok, response} = HTTPoison.get "http://elixirstatus.com/rss"
    %{body: body} = response
    body
  end

  defp parse_feed(feed) do
    {:ok, feed, _} = FeederEx.parse feed
    feed.entries
  end

  defp convert_feed_dates(feed) do
    feed
    |> Enum.map(&entry_date_to_timestamp/1)
  end

  defp filter_posted(feed) do
    last_timestamp = case get_last_timestamp() do
      {:error, :none} ->
        Logger.warn "There was no last timestamp for :elixirstatus, so we use the last entry"

        # If there's no last timestamp, assume it's the most recent entry so if
        # you deploy this app to a new server you'll not get duplicated entries
        feed
        |> hd
        |> Map.fetch!(:updated)

      {:ok, value} -> value
    end

    Logger.info "Last timestamp for :elixirstatus was #{last_timestamp}"

    feed
    |> Enum.filter(fn entry ->
      entry.updated > last_timestamp
    end)
  end

  defp send_to_channel([]), do: ExStatsD.increment("feeds.elixirstatus.noop")
  defp send_to_channel(feed) do
    ExStatsD.increment("feeds.elixirstatus.update")

    last_entry = feed
                 |> Enum.reverse
                 |> Enum.map(&format_entry/1)
                 |> List.last

    set_last_timestamp last_entry.updated
  end

  defp format_entry(entry) do
    text = """
    *#{HtmlEntities.decode entry.title}*

    #{entry.link}
    """
    Nadia.send_message @channel, text, parse_mode: "markdown"

    entry
  end

  # Helpers

  defp get_last_timestamp do
    Persistor.get @feed_id, "last_timestamp"
  end

  defp set_last_timestamp(nil), do: nil
  defp set_last_timestamp(timestamp) do
    Logger.info "Setting :elixirstatus last timestamp to #{timestamp}"

    Persistor.set @feed_id, "last_timestamp", timestamp
  end

  defp entry_date_to_timestamp(entry) do
    entry
    |> Map.update(:updated, 0, &from_rfc2822_to_unix/1)
  end

  defp from_rfc2822_to_unix(date) do
    with {:ok, date} <- Calendar.DateTime.Parse.rfc2822_utc(date),
         {:ok, date} <- Calendar.DateTime.Format.unix(date) do
      date
    end
  end
end
