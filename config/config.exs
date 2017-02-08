use Mix.Config

config :app,
  storage_dir: "./storage",
  bot_name: "elixir_lang_test_bot",
  elixirstatus_channel: "-1001088152256",
  pctguama_channel: "-1001110185325",
  relixir_channel: "-1001117355733",
  elixir_forum_channel: "-1001072257364"

config :nadia,
  token: System.get_env("BOT_TOKEN")

config :ex_statsd,
       host: "localhost",
       port: 8125,
       namespace: "elixir_lang_bot"

import_config "#{Mix.env}.exs"
