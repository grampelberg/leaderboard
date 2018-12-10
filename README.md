# Autoscaling on latency

## Prerequisites

- [Linkerd CLI](https://linkerd.io/2/getting-started/): `curl -sL https://run.linkerd.io/install | sh`
- [Helm](https://helm.sh/)

## Install system components

This will add the
[Linkerd control plane](https://linkerd.io/2/architecture/#control-plane) to
your cluster and install the
[Prometheus adapter](https://github.com/DirectXMan12/k8s-prometheus-adapter)
configured with latency queries. You can check out
[the file](hpa/prometheus-adapter.yml) if you'd like to add your own queries.

```bash
make setup-system
```

To verify that everything worked, you can run:

```bash
linkerd check

kubectl get --raw /apis/custom.metrics.k8s.io/v1beta1 | jq .
```

Note: it will take a little while for this to all start, so be patient.

## Install the demo app

This will add the [leaderboard](leaderboard.yml), a
[load balancer](external.yml) and [load generator](load.yml) to the cluster. It
will then add the `web` deployment to Linkerd's data plane and apply the
[HPA policy](hpa/policy.yml).

```bash
make demo
```

To verify that everything worked, you can run:

```bash
linkerd check --proxy

linkerd -n leaderboard stat deploy/web
```

## Start scaling

The load generator starts at 1k RPS. You can scale it up (or down) to modify the
load. Run:

```bash
kubectl -n leaderboard scale deploy/slow-cooker --replicas=10
```

Watch the metrics either via the Linkerd dashboard or the CLI by running:

## Development

### Locally

```bash
make dev
make serve
```
