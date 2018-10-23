defmodule Replicator do
  @moduledoc """
  A simple gen server that starts up App processes under the AppsSupervisor
  """
  use GenServer

  require Logger

  def get_list_namespace(server) do
    Kazan.Apis.Core.V1.list_namespace!()
    |> Kazan.run(server: server)
  end

  @doc """
  only bootstrap
  """
  def create_all_secrets do
    with server <- get_connection,
         {:ok, namespaces} <- get_list_namespace(server),
         secrets = Application.fetch_env!(:replicator, :secrets) do
      secrets
      |> Enum.map(&ref_secret(server, &1))
      |> Enum.each(&create_new_secret(&1, server, namespaces.items))

      {_, cheat} = get_list_namespace(server)
      {:ok, cheat.metadata.resource_version}
    else
      err -> {:error, err}
    end
  end

  def init_watcher(resource_version) do
    Kazan.Apis.Core.V1.watch_namespace_list!()
    |> Kazan.Watcher.start_link(
      server: get_connection,
      resource_version: resource_version,
      send_to: self()
    )
  end

  def start_link() do
    with {:ok, rv} <- create_all_secrets do
      GenServer.start_link(__MODULE__, %{resource_version: rv, error: 0})
    else
      {_reason, _code, msg} -> Logger.error("Error: #{Map.get(msg, "message")}")
    end
  end

  def init(%{resource_version: rv, error: _error} = state) do
    init_watcher(rv)
    {:ok, state}
  end

  def get_connection do
    Kazan.Server.from_kubeconfig("/home/rdesousa/.kube/config")
  end

  def ref_secret(server, %{namespace: namespace, secret: secret}) do
    namespace
    |> Kazan.Apis.Core.V1.read_namespaced_secret!(secret)
    |> Kazan.run(server: server)
  end

  def create_new_secret({:ko, {_reason, _code, msg}}, _server, _namespace) do
    Logger.error("Generation secret fail: #{msg.message}")
  end

  def create_new_secret({:ok, secret}, server, namespaces) do
    for namespace <- namespaces do
      new_secret_from_copy(secret)
      |> Kazan.Apis.Core.V1.create_namespaced_secret!(namespace.metadata.name)
      |> Kazan.run(server: server)
      |> case do
        {:ok, _} ->
          Logger.info("#{secret.metadata.name} is created in #{namespace.metadata.name}")

        {:error, {_reason, _code, msg}} ->
          Logger.error("#{Map.get(msg, "message")} in namespace #{namespace.metadata.name}")
      end
    end
  end

  def handle_info(%Kazan.Watcher.Event{object: _object, from: _pid, type: :gone}, %{
        resource_version: _rv,
        error: error
      }) do
    Logger.info("Too old resource version")

    case error do
      10 ->
        Logger.error("10 unsucces successive tries. Watcher is dead")
        {:stop, :normal, nil}

      _ ->
        Logger.info("Restart watcher")
        Process.sleep(1000)
        {:noreply, %{resource_version: create_all_secrets, error: error + 1}}
    end
  end

  def handle_info(
        %Kazan.Watcher.Event{object: object, from: _pid, type: type},
        %{
          resource_version: rv,
          error: _error
        }
      ) do
    case type do
      :added ->
        Logger.debug("New namespace: #{object.metadata.name}")
        server = get_connection

        Application.fetch_env!(:replicator, :secrets)
        |> Enum.map(&ref_secret(server, &1))
        |> Enum.each(&create_new_secret(&1, server, [object]))

        {_, cheat} = get_list_namespace(server)
        {:noreply, %{resource_version: cheat.metadata.resource_version, error: 0}}

      _ ->
        {:noreply, %{resource_version: rv, error: 0}}
    end
  end

  def terminate(_, _state) do
    Logger.error("Watcher k8s is dead")
  end

  def new_secret_from_copy(map) do
    %Kazan.Apis.Core.V1.Secret{
      api_version: map.api_version,
      data: map.data,
      kind: map.kind,
      type: map.type,
      metadata: %Kazan.Models.Apimachinery.Meta.V1.ObjectMeta{
        name: map.metadata.name,
        labels: map.metadata.labels
      }
    }
  end
end
