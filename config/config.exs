use Mix.Config

config :app,
  storage_dir: "./storage",
  bot_name: "elixir_lang_test_bot",
  elixirstatus_channel: "@elixirstatus_dev"

config :nadia,
  token: System.get_env("BOT_TOKEN")

import_config "#{Mix.env}.exs"
