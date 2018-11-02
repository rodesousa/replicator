defmodule Main do
  use Application

  def start(_type, _args) do
    get_connection()
    |> Replicator.start_link()
  end

  def get_connection() do
    Mix.env()
    |> case do
      :prod -> Kazan.Server.in_cluster()
      :dev -> Kazan.Server.from_kubeconfig(Application.fetch_env!(:replicator, :kube_config))
    end
  end
end
