defmodule Main do
  use Application

  def start(_type, _args) do
    Configuration.fetch_configuration()
    |> Replicator.start_link()
  end
end
