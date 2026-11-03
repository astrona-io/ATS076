# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. This lab was built without running it, so the text describes what you should see instead of printing output.

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS076.git -c sections/section-040/module-02/labs/lab-01
```

`astrona submit` right after the start shows one passing check: `other-attributes-kept`.

## Step 1: Read the statements

```sh
kubectl -n observability get configmap otelcol-config -o jsonpath='{.data.config\.yaml}'
```

The processor copies each legacy value to the stable name and then runs `delete_key` on the legacy name. The deletes remove what the old dashboards need.

## Step 2: Replace deletes with copies in both directions

```sh
kubectl -n observability edit configmap otelcol-config
```

Replace the four statements with:

```yaml
          - set(span.attributes["http.request.method"], span.attributes["http.method"]) where span.attributes["http.method"] != nil
          - set(span.attributes["http.method"], span.attributes["http.request.method"]) where span.attributes["http.request.method"] != nil
          - set(span.attributes["http.response.status_code"], span.attributes["http.status_code"]) where span.attributes["http.status_code"] != nil
          - set(span.attributes["http.status_code"], span.attributes["http.response.status_code"]) where span.attributes["http.response.status_code"] != nil
```

The first statement of each pair fills the stable name for a legacy span. The second fills the legacy name for a stable span, and for a legacy span it writes the same value again. Restart:

```sh
kubectl -n observability rollout restart deployment/otelcol
kubectl -n observability rollout status deployment/otelcol
```

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS076.git -c sections/section-040/module-02/labs/lab-01
```
