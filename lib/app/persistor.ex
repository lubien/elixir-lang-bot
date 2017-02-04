defmodule App.Persistor do
  require Logger

  # Public API

  def get(feed_id, key) do
    stash_id = String.to_atom(feed_id)

    case Stash.get stash_id, key do
      nil ->
        {:error, :none}
      timestamp ->
        IO.inspect timestamp
        {:ok, timestamp}
    end
  end

  def set(feed_id, key, data) do
    stash_id = String.to_atom(feed_id)

    true = Stash.set stash_id, key, data
    :ok = Stash.persist stash_id, stash_file(feed_id)
  end

  def load_stash(feed_id) do
    Logger.info "Loading @#{feed_id} Stash"

    stash_id = String.to_atom(feed_id)

    case Stash.load stash_id, stash_file(feed_id) do
      {:error, {_, reason, code}} ->
        Logger.warn "#{code} #{reason}"
      :ok ->
        Logger.info ":#{feed_id} stash loaded successfully"
    end
  end

  # Helpers

  defp stash_file(feed_id) do
    Path.join(App.storage_dir, "#{feed_id}.cache")
  end
end
