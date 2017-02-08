defmodule App.Feed.Rss do
  alias App.Feed.Formatter

  defmacro __using__(_opts) do
    quote do
      require Logger
      import App.Feed.Rss
      alias App.Persistor
      alias App.Feed.Formatter

      # Public API

      def init do
        Persistor.load_stash @feed_id
      end

      def tick do
        retreive_feed(@url)
        |> filter_posted
        |> send_to_channel
      end

      # Private API

      defp filter_posted(feed) do
        last_timestamp = case get_last_timestamp() do
          {:error, :none} ->
            Logger.warn "There was no last timestamp for :#{@feed_id}, so we use the last entry"

            # If there's no last timestamp, assume it's the most recent entry so if
            # you deploy this app to a new server you'll not get duplicated entries
            # feed
            # |> hd
            # |> Map.fetch!(:updated)
            # Comment so I could start my feed with some entries (:
            0

          {:ok, value} ->
            value
        end

        Logger.info "Last timestamp for :#{@feed_id} was #{last_timestamp}"

        feed
        |> Enum.filter(fn entry ->
          entry.updated > last_timestamp
        end)
      end

      defp send_to_channel([]), do: ExStatsD.increment("feeds.#{@feed_id}.noop")
      defp send_to_channel(feed) do
        ExStatsD.increment "feeds.#{@feed_id}.update"

        last_entry = feed
                     |> Enum.reverse
                     |> Enum.map(&send_entry/1)
                     |> List.last

        set_last_timestamp last_entry.updated
      end

      defp send_entry(entry) do
        text = Formatter.format_entry entry

        Nadia.send_message @channel, text, parse_mode: "markdown"
        ExStatsD.increment "feeds.#{@feed_id}.entries"

        entry
      end

      # Helpers

      defp get_last_timestamp do
        Persistor.get @feed_id, "last_timestamp"
      end

      defp set_last_timestamp(nil), do: nil
      defp set_last_timestamp(timestamp) do
        Logger.info "Setting :#{@feed_id} last timestamp to #{timestamp}"

        Persistor.set @feed_id, "last_timestamp", timestamp
      end
    end
  end

  def retreive_feed(url) do
    url
    |> get_feed
    |> parse_feed
    |> convert_feed_dates
  end

  defp get_feed(url) do
    {:ok, response} = HTTPoison.get url
    %{body: body} = response
    body
  end

  defp parse_feed(feed) do
    {:ok, feed, rest} = FeederEx.parse feed
    feed.entries
  end

  defp convert_feed_dates(feed) do
    feed
    |> Enum.map(&Formatter.rss_date_to_timestamp/1)
  end
end
