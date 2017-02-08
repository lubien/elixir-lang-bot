use Mix.Config

config :app,
  bot_name: "elixir_lang_bot",
  elixirstatus_channel: "@elixirstatus",
  pctguama_channel: "@pctguama",
  storage_dir: "/app/storage/"

config :ex_statsd,
       host: System.get_env("DOGSTATSD_PORT_8125_UDP_ADDR")
