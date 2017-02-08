defmodule App.Feed.RElixir do
  @behaviour App.Feed
  @feed_id "rElixir"
  @channel Application.get_env(:app, :relixir_channel)
  @url "https://www.reddit.com/r/elixir/new.rss"
  @date_format "rfc3339"
  @render_mode "html"
  use App.Feed.Rss
end
