# Question

Solve this question on: `terminal`

The Collector in `observability` must receive traces over OTLP/HTTP (port 4318), drop health check spans (the span name `GET /healthz`), export every other span with the `debug` exporter and answer health probes on port 13133. A first review found that applications cannot export, and that the health probe fails. Once exports work, other spans disappear too.

1. Fix the receiver so that port 4318 accepts spans.
2. Fix the processor so that only spans named `GET /healthz` are dropped.
3. Fix the health check so that port 13133 answers `200`.
4. Record the evidence in a ConfigMap `pipeline-evidence` in `observability` with these keys:
   - `receiver`, `processor` and `health`: one line each that names the cause of the fault you found at that stage.
   - `observed-at`: the time of your last check in UTC, in the form `2026-11-03T10:15:00Z`.

`kubectl` already points at the cluster. The configuration is the key `config.yaml` of the ConfigMap `otelcol-config`. Restart the Deployment after a change. The `shuttle` pod in `starfleet` has `curl`.
