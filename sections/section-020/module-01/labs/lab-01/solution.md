# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. This lab was built without running it, so the text describes what you should see instead of printing output.

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS076.git -c sections/section-020/module-01/labs/lab-01
```

`astrona submit` right after the start shows one passing check: `collector-healthy`. It stays your guard.

## Step 1: Reproduce the failure

```sh
kubectl -n starfleet exec deploy/shuttle -- curl -s -o /dev/null -w '%{http_code}\n' -X POST -H 'Content-Type: application/json' -d '{"resourceSpans":[]}' http://otelcol.observability:4318/v1/traces
```

curl cannot connect: it prints `000` as the status code, because no process listens on port 4318. The Service forwards the connection, but the Collector has no listener.

## Step 2: Compare definitions and pipelines

```sh
kubectl -n observability get configmap otelcol-config -o jsonpath='{.data.config\.yaml}'
```

The `receivers` section defines `otlp/grpc` and `otlp/http`. The `traces` pipeline lists only `otlp/grpc`. The Collector starts only the components that a pipeline uses, so `otlp/http` never starts.

## Step 3: Add the receiver to the pipeline

```sh
kubectl -n observability edit configmap otelcol-config
```

Change `receivers: [otlp/grpc]` to `receivers: [otlp/grpc, otlp/http]`. Restart the Collector:

```sh
kubectl -n observability rollout restart deployment/otelcol
kubectl -n observability rollout status deployment/otelcol
```

Repeat the request from step 1. The status code is now `200`. The `debug` exporter prints the spans you send in the Collector log: `kubectl -n observability logs deploy/otelcol`.

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS076.git -c sections/section-020/module-01/labs/lab-01
```

All three checks pass.
