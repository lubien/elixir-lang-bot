defmodule App do
  use Application

  @storage_dir Path.expand Application.get_env(:app, :storage_dir)

  def storage_dir do
    unless File.exists?(@storage_dir) do
      File.mkdir(@storage_dir)
    end

    @storage_dir
  end

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(App.Poller, []),
      worker(App.Matcher, []),
      worker(App.FeedsPoller, [])
    ]

    opts = [strategy: :one_for_one, name: App.Supervisor]
    Supervisor.start_link children, opts
  end
end
