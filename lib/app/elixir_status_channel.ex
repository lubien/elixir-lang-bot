defmodule App.ElixirStatusChannel do
  require Logger

  @channel "@elixirstatus"
  @stash_file Path.join(App.storage_dir, "elixirstatus.cache")

  def update do
    Logger.log :info, "Triggered update"

    get_feed
    |> parse_feed
    |> filter_already_posted
    |> send_to_channel
  end

  def get_feed do
    {:ok, response} = HTTPoison.get "http://elixirstatus.com/rss"
    %HTTPoison.Response{body: body} = response
    body
  end

  def parse_feed(feed) do
    {:ok, feed, _} = FeederEx.parse feed
    feed.entries
  end

  def filter_already_posted(feed) do
    last_timestamp = get_last_timestamp

    Logger.log :info, "Last timestamp was #{last_timestamp}"

    feed
    |> Stream.map(&entry_date_to_timestamp/1)
    |> Stream.filter(fn entry ->
      entry.updated > last_timestamp
    end)
  end

  def send_to_channel(feed) do
    last_entry = feed
    |> Enum.reverse
    |> Enum.map(fn entry ->
      text = """
      *#{HtmlEntities.decode entry.title}*

      #{entry.link}
      """
      Nadia.send_message @channel, text, parse_mode: "markdown"

      entry
    end)
    |> List.last

    set_last_timestamp last_entry
  end

  # Helpers

  def load_stash do
    Logger.log :info, "Loading :elixistatus Stash"

    result = case Stash.load :elixirstatus, @stash_file do
      {:error, {_, reason, code}} ->
        Logger.log :warn, "#{code} #{reason}"
      :ok ->
        Logger.log :info, "Loaded successfully"
    end
  end

  defp get_last_timestamp do
    case Stash.get(:elixirstatus, "last_timestamp") do
      nil ->
        0
      timestamp ->
        timestamp
    end
  end

  defp set_last_timestamp(nil), do: nil
  defp set_last_timestamp(entry) do
    Logger.log :info, "Setting timestamp to #{entry.updated}"

    true = Stash.set :elixirstatus, "last_timestamp", entry.updated
    :ok = Stash.persist :elixirstatus, @stash_file
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
