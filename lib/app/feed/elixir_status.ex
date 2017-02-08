defmodule App.Feed.ElixirStatus do
  @behaviour App.Feed
  @feed_id "elixirstatus"
  @channel Application.get_env(:app, :elixirstatus_channel)
  @url "http://elixirstatus.com/rss"
  use App.Feed.Rss
end
