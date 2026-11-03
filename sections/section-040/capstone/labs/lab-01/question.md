# Question

Solve this question on: `terminal`

Services in `starfleet` use two generations of OpenTelemetry instrumentation. Older services send `http.method`, `http.status_code` and `net.peer.name`. The backend and its queries are moving to the stable names. The Collector `otelcol` in `observability` exports to the `debug` exporter and has no processor yet.

1. Rename `http.method` to `http.request.method` and `http.status_code` to `http.response.status_code`. The legacy names must disappear.
2. For `net.peer.name`, the team needs a compatibility window: keep `net.peer.name` and add `server.address` with the same value.
3. A span that already uses the stable names must keep its values, and every other attribute must stay unchanged.
4. Record the evidence in a ConfigMap `schema-evidence` in `observability` with these keys:
   - `renamed` and `dual-emitted`: one line each that names the attributes you handled.
   - `observed-at`: the time of your last check in UTC, in the form `2026-11-03T10:15:00Z`.

`kubectl` already points at the cluster. The configuration is the key `config.yaml` of the ConfigMap `otelcol-config`. Restart the Deployment after a change. Use a `transform` processor with context-prefixed paths such as `span.attributes`.
