# Solution

Solve this lab on `terminal`. This lab was built without running it, so the text describes what you should see instead of printing output.

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS076.git -c sections/section-040/capstone/labs/lab-01
```

## Step 1: Add one processor with both behaviors

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
      - set(span.attributes["server.address"], span.attributes["net.peer.name"]) where span.attributes["net.peer.name"] != nil
```

Add `processors: [transform/semconv]` to the `traces` pipeline above `exporters`. The first four statements rename. The last statement copies and does not delete, so both names stay. Restart:

```sh
kubectl -n observability rollout restart deployment/otelcol
kubectl -n observability rollout status deployment/otelcol
```

## Step 2: Check

Send a span with the legacy attributes (see the question) and read `kubectl -n observability logs deploy/otelcol --tail=60`: it shows the stable HTTP names, `net.peer.name` and `server.address`.

## Step 3: Record the evidence

Save this as `schema-evidence.yaml`, replacing the time with the current UTC time:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: schema-evidence
  namespace: observability
data:
  renamed: "http.method to http.request.method and http.status_code to http.response.status_code; legacy names removed"
  dual-emitted: "net.peer.name is kept and server.address is added"
  observed-at: "2026-11-03T10:15:00Z"
```

```sh
kubectl apply -f schema-evidence.yaml
astrona submit --git ssh://git@github.com/astrona-io/ATS076.git -c sections/section-040/capstone/labs/lab-01
```
