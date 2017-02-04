use Mix.Config

config :app,
  storage_dir: "./storage",
  bot_name: "elixir_lang_test_bot",
  elixirstatus_channel: "@elixirstatus_dev"

config :nadia,
  token: System.get_env("BOT_TOKEN")

config :ex_statsd,
       host: "localhost",
       port: 8125,
       namespace: "elixirstatus"

import_config "#{Mix.env}.exs"
