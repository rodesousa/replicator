defmodule SecretWatcher do
  @moduledoc """
  """
  use GenServer

  require Logger

  def start_link(server) do
    # run a fake request to get a new resource version
    with {:ok, fake_request} <-
           server
           |> NamespaceHelper.get_list_namespace() do
      GenServer.start_link(__MODULE__, %{
        server: server,
        resource_version: fake_request.metadata.resource_version
      })
    end
  end

  def init(state) do
    Application.fetch_env!(:replicator, :secrets)
    |> Enum.map(&initWatcher(&1, state))

    {:ok, state}
  end

  defp initWatcher(%{namespace: ns, secret: secret}, %{server: server, resource_version: rv}) do
    ns
    |> Kazan.Apis.Core.V1.watch_namespaced_secret!(secret)
    |> Kazan.Watcher.start_link(
      server: server,
      resource_version: rv,
      send_to: self()
    )
  end

  def handle_info(
        %Kazan.Watcher.Event{object: secret, from: _pid, type: :modified},
        %{server: server} = state
      ) do
    Logger.info("The #{secret.metadata.name} of #{secret.metadata.namespace} namespace changed")

    with {:ok, namespaces} <- NamespaceHelper.get_list_namespace(server) do
      # must not delete the reference secret
      namespaces.items
      |> Enum.filter(fn ns -> ns.metadata.name != secret.metadata.namespace end)
      |> Enum.map(fn namespace ->
        namespace.metadata.name
        |> SecretHelper.delete(secret.metadata.name, server)

        clean_secret =
          secret
          |> SecretHelper.copy_from_request()

        namespace.metadata.name
        |> SecretHelper.create(clean_secret, server)
        |> case do
          {:ok, _} ->
            Logger.info(
              "Secret: #{clean_secret.metadata.name} Updated in #{namespace.metadata.name}"
            )

          {:error, {_reason, _code, msg}} ->
            Logger.error("#{Map.get(msg, "message")} in namespace #{namespace.metadata.name}")
        end
      end)

      Logger.info("All secrets updated")
    else
      {:error, _response} -> Logger.info("Secrets not updated")
    end

    {:noreply, state}
  end

  def handle_info(%Kazan.Watcher.Event{object: object, from: pid, type: type}, state) do
    case type do
      :gone -> {:stop, state}
      _ -> {:noreply, state}
    end
  end
end
