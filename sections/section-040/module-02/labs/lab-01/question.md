# Question

Solve this question on: `terminal`

The Collector `otelcol` in `observability` runs a `transform/semconv` processor that renames the legacy HTTP attributes (`http.method`, `http.status_code`) to the stable names (`http.request.method`, `http.response.status_code`) and deletes the legacy names. Old dashboards still query the legacy names and now show no data. The team decides on a migration window in which every span carries both names.

1. Change `transform/semconv` so that a span that has a legacy attribute also gets the stable attribute, and a span that has a stable attribute also gets the legacy one. Neither name may be deleted.
2. The values of both names must be equal. Every other attribute must stay unchanged.

`kubectl` already points at the cluster. The configuration is the key `config.yaml` of the ConfigMap `otelcol-config`. Restart the Deployment after a change. Use the OpenTelemetry Transformation Language (OTTL) with context-prefixed paths such as `span.attributes`.
