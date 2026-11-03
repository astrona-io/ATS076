# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check. This lab was built without running it, so the text describes what you should see instead of printing output.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS076.git -c sections/section-030/module-03/labs/lab-01
```

## Step 1: Send a span and read the log

```sh
kubectl -n starfleet exec deploy/shuttle -- curl -s -o /dev/null -w '%{http_code}\n' -X POST -H 'Content-Type: application/json' -d '{"resourceSpans":[{"resource":{"attributes":[{"key":"service.name","value":{"stringValue":"scout"}}]},"scopeSpans":[{"scope":{"name":"lab"},"spans":[{"traceId":"5b8efff798038103d269b633813fc60c","spanId":"eee19b7ec3c1b174","name":"lab-probe","kind":2,"startTimeUnixNano":"1700000000000000000","endTimeUnixNano":"1700000001000000000"}]}]}]}' http://otelcol.observability:4318/v1/traces
kubectl -n observability logs deploy/otelcol --tail=50
```

The status is 200. The log of `otelcol` has a line that says the export failed and the data was dropped. The error text names the status 404 and a URL that ends in `/v1/traces/v1/traces`.

## Step 2: Find the cause

```sh
kubectl -n observability get configmap otelcol-config -o jsonpath='{.data.config\.yaml}'
```

The `endpoint` of `otlp_http/backend` ends in `/v1/traces`. The exporter adds the path itself, so the request goes to the path twice. The status 404 is permanent, so the exporter drops the data and does not retry.

## Step 3: Fix the endpoint and restart

```sh
kubectl -n observability edit configmap otelcol-config
```

Change the endpoint to `http://backend.observability:4318`. Then restart the Collector:

```sh
kubectl -n observability rollout restart deployment/otelcol
kubectl -n observability rollout status deployment/otelcol
```

Send a new span as in step 1. The span name appears in the log of the `backend`.

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS076.git -c sections/section-030/module-03/labs/lab-01 --keep
```

All checks pass.
