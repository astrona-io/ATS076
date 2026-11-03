# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. This lab was built without running it, so the text describes what you should see instead of printing output.

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS076.git -c sections/section-020/module-02/labs/lab-01
```

`astrona submit` right after the start shows one passing check: `metrics-endpoint-up`. It stays your guard.

## Step 1: Compare accepted and sent counts

Send two spans, then read the internal metrics:

```sh
kubectl -n starfleet exec deploy/shuttle -- curl -s -X POST -H 'Content-Type: application/json' -d '{"resourceSpans":[{"resource":{},"scopeSpans":[{"scope":{},"spans":[{"traceId":"5b8efff798038103d269b633813fc60c","spanId":"eee19b7ec3c1b174","name":"POST /checkout","kind":2,"startTimeUnixNano":"1700000000000000000","endTimeUnixNano":"1700000001000000000"}]}]}]}' http://otelcol.observability:4318/v1/traces
kubectl -n starfleet exec deploy/shuttle -- curl -s http://otelcol.observability:8888/metrics | grep -E 'otelcol_(receiver_accepted_spans|exporter_sent_spans|processor_incoming_items|processor_outgoing_items)'
```

The receiver counter grows, the processor outgoing counter does not, and the debug exporter prints nothing for the span. The loss happens inside the processor.

## Step 2: Read the condition

```sh
kubectl -n observability get configmap otelcol-config -o jsonpath='{.data.config\.yaml}'
```

The condition is `span.name != "GET /healthz"`. A `filter` processor drops a span when a condition is true. This condition is true for every span except the health check, so the processor drops everything else.

## Step 3: Invert the condition and restart

```sh
kubectl -n observability edit configmap otelcol-config
```

Change `!=` to `==`. Then:

```sh
kubectl -n observability rollout restart deployment/otelcol
kubectl -n observability rollout status deployment/otelcol
```

Send the `POST /checkout` span again: it is now printed in the Collector log. A span named `GET /healthz` is not.

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS076.git -c sections/section-020/module-02/labs/lab-01
```
