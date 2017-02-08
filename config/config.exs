use Mix.Config

config :app,
  storage_dir: "./storage",
  bot_name: "elixir_lang_test_bot",
  elixirstatus_channel: "-1001088152256",
  pctguama_channel: "-1001110185325",
  relixir_channel: "-1001117355733",
  elixir_forum_channel: "-1001072257364",
  statsd_host: "127.0.0.1"

config :nadia,
  token: System.get_env("BOT_TOKEN")

import_config "#{Mix.env}.exs"
