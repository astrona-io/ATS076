# Solution

Solve this lab on `terminal`. This lab was built without running it, so the text describes what you should see instead of printing output.

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS076.git -c sections/section-020/capstone/labs/lab-01
```

## Step 1: Read the whole configuration once

```sh
kubectl -n observability get configmap otelcol-config -o jsonpath='{.data.config\.yaml}'
```

Compare three pairs. First, the receivers `otlp/grpc` and `otlp/http` are defined, but the `traces` pipeline lists only `otlp/grpc`. Second, the condition of `filter/health` is `span.name != "GET /healthz"`, which is true for every span except the health check. Third, the extension `health_check` is defined, but `service.extensions` is an empty list.

## Step 2: Fix all three

```sh
kubectl -n observability edit configmap otelcol-config
```

Change the pipeline to `receivers: [otlp/grpc, otlp/http]`, change `!=` to `==` in the condition, and set `extensions: [health_check]` under `service`. Restart:

```sh
kubectl -n observability rollout restart deployment/otelcol
kubectl -n observability rollout status deployment/otelcol
```

## Step 3: Check each stage

```sh
kubectl -n starfleet exec deploy/shuttle -- curl -s -o /dev/null -w '%{http_code}\n' http://otelcol.observability:13133/
kubectl -n starfleet exec deploy/shuttle -- curl -s http://otelcol.observability:8888/metrics | grep -E 'otelcol_(receiver_accepted_spans|exporter_sent_spans)'
```

The health check answers `200`. Send a `POST /checkout` span and a `GET /healthz` span to port 4318 and read `kubectl -n observability logs deploy/otelcol`: only the first one is printed.

## Step 4: Record the evidence

Save this as `pipeline-evidence.yaml`, replacing the time with the current UTC time:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: pipeline-evidence
  namespace: observability
data:
  receiver: "otlp/http was defined but not listed in the traces pipeline"
  processor: "filter/health condition was inverted and dropped every span except GET /healthz"
  health: "health_check was defined but not listed in service.extensions"
  observed-at: "2026-11-03T10:15:00Z"
```

```sh
kubectl apply -f pipeline-evidence.yaml
astrona submit --git ssh://git@github.com/astrona-io/ATS076.git -c sections/section-020/capstone/labs/lab-01
```
