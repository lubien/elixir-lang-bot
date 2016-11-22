use Mix.Config

config :app,
  bot_name: System.get_env("BOT_NAME"),
  storage_dir: "./storage"

config :nadia,
  token: System.get_env("BOT_TOKEN")

import_config "#{Mix.env}.exs"
