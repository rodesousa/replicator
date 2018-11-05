# Replicator

**TODO: Add description**


## Dev

Get back dependencies:
```
make dep
```

Use iex for dev:
```
iex -s mix compile
```

There is a [dev.exs](./config/dev.exs) file configured for a local kube config and a example of secret

You need to change a path:
```
  kube_config: "/home/rdesousa/.kube/config"
```

### How put secrets ?

In [dev.exs](./config/dev) put:
```
config :replicator,
  secrets: [
    %{secret: "foo", namespace: "bar"}
  ]
```

## Prod

Use [chart](./chart/replicator)

Prod env use `ca.cert` and `token` (in a pod) for the connection of k8s cluster

### You need test `secrets_file` in dev ?

Put a `test.exs` in project root with secrets list:
```
use Mix.Config

config :replicator,
  secrets: [
    %{secret: "TEST", namespace: "TEST"}
  ]
```

## TODO

+ Don't debug log in prod
+ Improve logging
+ Add CI
+ Add test
+ change map list secrets to keyword lists
+ When restart (resource_version too old) keep a list of namespace (in state for example) treated and create the secrets only new namespaces
