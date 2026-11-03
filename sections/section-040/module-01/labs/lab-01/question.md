# Question

Solve this question on: `terminal`

Services in `starfleet` use two generations of OpenTelemetry instrumentation. Older services send the HTTP attributes `http.method` and `http.status_code`. Newer services send the stable names `http.request.method` and `http.response.status_code`. The backend dashboards query only the stable names. The Collector `otelcol` in `observability` exports to the `debug` exporter.

1. Add a `transform` processor named `transform/semconv` to the traces pipeline.
2. For a span that has `http.method`, set `http.request.method` to its value and remove `http.method`. Do the same for `http.status_code` and `http.response.status_code`.
3. A span that already uses the new names must keep its values, and every other attribute must stay unchanged.

`kubectl` already points at the cluster. The configuration is the key `config.yaml` of the ConfigMap `otelcol-config`. Restart the Deployment after a change. Use the OpenTelemetry Transformation Language (OTTL) with context-prefixed paths such as `span.attributes`.
