defmodule Main do
  use Application

  require Logger

  def start(_a, _b) do
    server = Configuration.fetch_configuration()

    server
    |> SecretWatcher.start_link()

    server
    |> NamespaceWatcher.start_link()
  end
end
