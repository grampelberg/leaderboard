# Autoscaling on latency

## Run

```bash
make yaml | kubectl apply -f -

kubectl apply -f external.yml

kubectl -n leaderboard get deploy web -o yaml | \
  linkerd inject --skip-outbound-ports=6379 - | \
  kubectl apply -f -

cat load.yml | \
  linkerd inject --proxy-log-level=warn,linkerd2_proxy=info,linkerd2_proxy::app::outbound::discovery=debug - | \
  kubectl apply -f -
```



## Development

### Locally

```bash
make dev
make serve
```

### In k8s

```bash
make yaml | kubectl apply -f -
```

## Steps

```bash
helm repo update

helm -n linkerd --namespace linkerd \
  install stable/prometheus-adapter \
  -f hpa/prometheus-adapter.yml

kubectl get --raw /apis/custom.metrics.k8s.io/v1beta1 | \
  jq . | grep latency

kubectl get --raw "/apis/custom.metrics.k8s.io/v1beta1/namespaces/leaderboard/pods/*/response_latency_ms_99th" | \
  jq .

kubectl apply -f hpa/policy.yml
```
