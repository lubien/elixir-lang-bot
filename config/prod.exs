use Mix.Config

config :app,
  bot_name: "elixir_lang_bot",
  elixirstatus_channel: "@elixirstatus",
  pctguama_channel: "@pctguama",
  relixir_channel: "@rElixir",
  elixir_forum_channel: "@elixir_forum",
  storage_dir: "/app/storage/",
  statsd_host: System.get_env("DOGSTATSD_PORT_8125_UDP_ADDR")
