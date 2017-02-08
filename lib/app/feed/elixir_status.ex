defmodule App.Feed.ElixirStatus do
  @behaviour App.Feed
  @feed_id "elixirstatus"
  @channel Application.get_env(:app, :elixirstatus_channel)
  @url "http://elixirstatus.com/rss"
  @date_format "rfc2822"
  @render_mode "markdown"
  use App.Feed.Rss
end
