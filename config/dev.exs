use Mix.Config

config :replicator,
  secrets: [
    %{secret: "mysecret", namespace: "default"}
  ],
  kube_config: "/home/rdesousa/.kube/config",
  secrets_file: "test.exs"
