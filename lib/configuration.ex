defmodule Configuration do
  use Mix.Config
  require Logger

  def fetch_configuration() do
    Application.get_env(:replicator, :environment)
    |> case do
      :prod ->
        Application.get_env(:replicator, :secrets_file)
        |> merge_secrets_env

        secrets_env
        Kazan.Server.in_cluster()

      :dev ->
        Kazan.Server.from_kubeconfig(Application.fetch_env!(:replicator, :kube_config))
    end
  end

  def merge_secrets_env(nil), do: nil

  def merge_secrets_env(path) do
    if File.exists?(path) do
      case Mix.Config.eval!(path) do
        nil ->
          Logger.info("Neither configuration file")

        {values, _path} ->
          Application.put_env(:replicator, :secrets, values[:replicator][:secrets])
      end
    end
  end

  def secrets_env() do
    unless Application.get_env(:replicator, :secrets) do
      raise "Neither configured secrets. Do you have put secrets ?"
    end
  end
end
