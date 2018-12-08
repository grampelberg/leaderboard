
![custom metrics](https://g.gravizo.com/svg?
  digraph G {

    aize ="4,4";
    main [shape=box];
    main -> parse [weight=8];
    parse -> execute;
    main -> init [style=dotted];
    main -> cleanup;
    execute -> { make_string; printf}
    init -> make_string;
    edge [color=red];
    main -> printf [style=bold,label="100 times"];
    make_string [label="make a string"];
    node [shape=box,style=filled,color=".7 .3 1.0"];
    execute -> compare;
  }
)

- requests to `/apis/metrics` are proxied to the metrics server
- metrics server
  - because etcd is not designed to handle metrics data
  - entirely in memory
  - only returns the latest value
  - can only be scaled vertically (addon-resizer)
  - scrapes the kubelet (summary api)

- system metrics
  - cpu
  - memory
- service metrics
  - success rate

# Steps

1. helm repo update
1. helm -n linkerd install stable/prometheus-adapter -f hpa/prometheus-adapter.yml
1. kubectl get --raw /apis/custom.metrics.k8s.io/v1beta1 | jq . | grep latency
