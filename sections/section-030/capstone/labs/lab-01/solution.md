# Solution

Solve this lab on `terminal`. This lab was built without running it, so the text describes what you should see instead of printing output.

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS076.git -c sections/section-030/capstone/labs/lab-01
```

## Step 1: Read the configuration

```sh
kubectl -n observability get configmap otelcol-config -o jsonpath='{.data.config\.yaml}'
```

Three faults show: the processors list is `[attributes/env, memory_limiter]` with `limit_mib: 4000`; the exporter `otlp_http/backend` has `enabled: false` for both `retry_on_failure` and `sending_queue`; the extension `file_storage/queue` is defined but not in `service.extensions`.

## Step 2: Fix them

```sh
kubectl -n observability edit configmap otelcol-config
```

Set `processors: [memory_limiter, attributes/env]`, `limit_mib: 150`, `spike_limit_mib: 30`. In the exporter set `retry_on_failure.enabled: true`, `sending_queue.enabled: true`, `queue_size: 5000` and `storage: file_storage/queue`. Set `extensions: [health_check, file_storage/queue]` under `service`. Restart:

```sh
kubectl -n observability rollout restart deployment/otelcol
kubectl -n observability rollout status deployment/otelcol
```

If the Collector does not start, read `kubectl -n observability logs deploy/otelcol`: a queue that names a storage extension fails at start when the extension is not enabled.

## Step 3: Record the evidence

Save this as `loss-evidence.yaml`, replacing the time with the current UTC time:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: loss-evidence
  namespace: observability
data:
  retry: "retry_on_failure is enabled for otlp_http/backend"
  queue: "sending_queue holds 5000 batches on disk through file_storage/queue"
  memory: "memory_limiter is first with limit_mib 150 for a 256Mi container"
  observed-at: "2026-11-03T10:15:00Z"
```

```sh
kubectl apply -f loss-evidence.yaml
astrona submit --git ssh://git@github.com/astrona-io/ATS076.git -c sections/section-030/capstone/labs/lab-01
```
