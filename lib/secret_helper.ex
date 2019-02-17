defmodule SecretHelper do
  @moduledoc """
  """
  require Logger

  @spec copy_from_request(Kazan.Apis.Core.V1.Secret.t()) :: Kazan.Apis.Core.V1.Secret.t()
  def copy_from_request(secret) do
    %Kazan.Apis.Core.V1.Secret{
      api_version: secret.api_version,
      data: secret.data,
      kind: secret.kind,
      type: secret.type,
      metadata: %Kazan.Models.Apimachinery.Meta.V1.ObjectMeta{
        name: secret.metadata.name,
        labels: secret.metadata.labels
      }
    }
  end

  @spec delete(String.t(), String.t(), Kazan.Server.t()) :: {:ok, struct}
  def delete(namespace, secret, server) do
    %Kazan.Models.Apimachinery.Meta.V1.DeleteOptions{}
    |> Kazan.Apis.Core.V1.delete_namespaced_secret!(namespace, secret)
    |> Kazan.run!(server: server)
  end

  @spec create(String.t(), Kanza.Apis.Core.V1.Secret.t(), Kazan.Server.t()) :: {:ok, struct}
  def create(namespace, secret, server) do
    secret
    |> Kazan.Apis.Core.V1.create_namespaced_secret!(namespace)
    |> Kazan.run(server: server)
  end

  @spec read(Kazan.Apis.Core.V1.Namespace.t(), Kazan.APis.Core.V1.Secret.t(), Kazan.Server.t()) ::
          {:ok, struct}
  def read(ns, secret, server) do
    ns.metadata.name
    |> Kazan.Apis.Core.V1.read_namespaced_secret!(secret.metadata.name)
    |> Kazan.run(server: server)
  end
end
