defmodule App.Feed.Formatter do
  def format_entry(entry) do
    """
    *#{HtmlEntities.decode entry.title}*

    #{entry.link}
    """
  end

  def rss_date_to_timestamp(entry) do
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
