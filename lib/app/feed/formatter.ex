defmodule App.Feed.Formatter do
  def format_entry(entry, "html") do
    """
    <b>#{HtmlEntities.decode entry.title}</b>

    #{entry.link}
    """
  end
  def format_entry(entry, _) do
    """
    *#{HtmlEntities.decode entry.title}*

    #{entry.link}
    """
  end

  def from_rfc2822_to_unix(date) do
    with {:ok, date} <- Calendar.DateTime.Parse.rfc2822_utc(date),
         {:ok, date} <- Calendar.DateTime.Format.unix(date) do
      date
    end
  end

  def from_rfc3339_to_unix(date) do
    with {:ok, date} <- Calendar.DateTime.Parse.rfc3339_utc(date),
         {:ok, date} <- Calendar.DateTime.Format.unix(date) do
      date
    end
  end
end
