# Replicator chart

Chart of [replicator](../..)

## Chart Details

This chart will implement replicator secret that copy a secret list in all namespaces

# Installing the Chart

(recommended) Put the chart in chart museum and:
```
helm install --name replicator --namespace foo REPO/replicator --values values.yaml
```

The chart can be customized using the following configurable parameters:

| Parameter          | Description                      | Default              |
| ------------------ | ---------------------------------| ---------------------|
| `image.repository`   | Replicator Container image name  | `rodesousa/replicator` |
| `image.tag`          | Replicator Container image tag   | `string`               |
| `image.pullPolicy`   | Replicator Container pull policy | `Always`               |
| `secrets`            | Secrets list to copy             | `[]`                   |
| `resources`          | Resource requests and limits     | `{}`                   |
| `tolerations`        | Tolerations for pod assignments  | `[]`                   |
| `affinity`           | Affinity settings                | `{}`                   |
