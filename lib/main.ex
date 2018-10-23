defmodule Main do
  use Application

  def start(_type, _args) do
    Replicator.start_link()
  end
end
