defmodule App.Feed.PCTGuama do
  @behaviour App.Feed
  @feed_id "pctguama"
  @channel Application.get_env(:app, :pctguama_channel)
  @url "http://pctguama.org.br/index.php/pt/feed/"
  use App.Feed.Rss
end
