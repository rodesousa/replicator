# Replicator

Kubernetes controller copies, updates and adds secrets in all the namespaces

## Description

Some secrets (ex: ssl certificate, registry credentials) should be present in all namespaces (imho, all namespaces should be independent)

The **replicator** controller takes a list of tuples (secret, namespace), reference secrets, and allow you to:

+ copy a reference secrets in all namespaces
+ update all reference secrets when a reference secrets changes
+ add a reference secrets in new namespaces

## Helm

[Chart Helm](./chart)

## Properties

| Parameter | Type | Description |
| --------- | ---- | ----------- |
| `replicator.secret` | %{secret:, String.t(), namespace: String.t()} | **dev only** Reference secret |
| `replicator.kube_config` | String.t() | **dev only** kube config file used by `kubectl` |
| `replicator.secrets_file` | String.t() | **prod only** Reference secret file built by helm [cm.yaml](./chart/replicator/templates/cm.yaml) |

## Lifecyle

Get back dependencies:
```
make dep
```

Use iex for dev:
```
iex -s mix compile
```

You need to change your kube config path to use it:
```
  kube_config: "/home/rdesousa/.kube/config"
```

** For Kazan in iex users, you have to use `HTTPoison.start`  in your console first**

## TODO

+ Add CI
+ Add test
+ change map list secrets to keyword lists
+ Refacto ./lib/namespace_*
