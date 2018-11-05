use Mix.Config

config :replicator,
  secrets: [
    %{secret: "registry.gitlab.com", namespace: "tools"}
  ],
  kube_config: "/home/rdesousa/.kube/config",
  secrets_file: "test.exs"
