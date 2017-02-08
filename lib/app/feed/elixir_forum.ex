defmodule App.Feed.ElixirForum do
  @behaviour App.Feed
  @feed_id "elixir_forum"
  @channel Application.get_env(:app, :elixir_forum_channel)
  @url "https://elixirforum.com/latest.rss"
  @date_format "rfc2822"
  @render_mode "markdown"
  use App.Feed.Rss
end
