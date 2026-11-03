# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. This lab was built without running it, so the text describes what you should see instead of printing output.

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS076.git -c sections/section-030/module-01/labs/lab-01
```

## Step 1: Read the exporter settings

```sh
kubectl -n observability get configmap otelcol-config -o jsonpath='{.data.config\.yaml}'
```

The exporter `otlp_http/backend` has `enabled: false` under both `retry_on_failure` and `sending_queue`. With both off, the exporter sends each request once, in the same call that the receiver made, and returns an error to the sender when the backend is unavailable.

## Step 2: Switch both on

```sh
kubectl -n observability edit configmap otelcol-config
```

Set `enabled: true` under `retry_on_failure`. Under `sending_queue`, set `enabled: true` and add `queue_size: 5000`. Restart:

```sh
kubectl -n observability rollout restart deployment/otelcol
kubectl -n observability rollout status deployment/otelcol
```

## Step 3: Check the queue capacity

```sh
kubectl -n starfleet exec deploy/shuttle -- curl -s http://otelcol.observability:8888/metrics | grep otelcol_exporter_queue_capacity
```

The line for `otlp_http/backend` ends with `5000`.

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS076.git -c sections/section-030/module-01/labs/lab-01 --keep
```

The check `queue-capacity` passes. The check `outage-survived` stops the `backend` for a short time, sends a span, starts it again and waits for the span in the backend log. It passes because the queue keeps the batch and the retry sends it again with an increasing delay.
