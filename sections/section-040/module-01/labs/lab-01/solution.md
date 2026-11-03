# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. This lab was built without running it, so the text describes what you should see instead of printing output.

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS076.git -c sections/section-040/module-01/labs/lab-01
```

`astrona submit` right after the start shows two passing checks: `other-attributes-kept` and `new-style-unchanged`. They stay your guards.

## Step 1: See the legacy names

Send a span with `http.method` and read the Collector log:

```sh
kubectl -n starfleet exec deploy/shuttle -- curl -s -X POST -H 'Content-Type: application/json' -d '{"resourceSpans":[{"resource":{},"scopeSpans":[{"scope":{},"spans":[{"traceId":"5b8efff798038103d269b633813fc60c","spanId":"eee19b7ec3c1b174","name":"legacy","kind":2,"startTimeUnixNano":"1700000000000000000","endTimeUnixNano":"1700000001000000000","attributes":[{"key":"http.method","value":{"stringValue":"GET"}}]}]}]}]}' http://otelcol.observability:4318/v1/traces
kubectl -n observability logs deploy/otelcol --tail=40
```

The attribute list shows `http.method`. Nothing in the pipeline renames it.

## Step 2: Add the processor

```sh
kubectl -n observability edit configmap otelcol-config
```

Add under `processors`:

```yaml
  transform/semconv:
    error_mode: ignore
    trace_statements:
      - set(span.attributes["http.request.method"], span.attributes["http.method"]) where span.attributes["http.method"] != nil
      - delete_key(span.attributes, "http.method")
      - set(span.attributes["http.response.status_code"], span.attributes["http.status_code"]) where span.attributes["http.status_code"] != nil
      - delete_key(span.attributes, "http.status_code")
```

Add `processors: [transform/semconv]` to the `traces` pipeline, above `exporters`. The `where` clause keeps the statement from copying a missing value over a new attribute. Restart:

```sh
kubectl -n observability rollout restart deployment/otelcol
kubectl -n observability rollout status deployment/otelcol
```

Send the span again: the log shows `http.request.method` and no `http.method`.

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS076.git -c sections/section-040/module-01/labs/lab-01
```
