defmodule NamespaceHelper do
  def get_list_namespace(server) do
    Kazan.Apis.Core.V1.list_namespace!()
    |> Kazan.run(server: server)
  end
end
