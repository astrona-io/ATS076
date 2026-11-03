# Question

Solve this question on: `terminal`

The Collector in `observability` receives traces over OTLP/HTTP and has a `filter/health` processor that must drop health check spans (the span name `GET /healthz`) so that they do not fill the backend. After a configuration change the `scout` team reports that no traces arrive at all, although the applications export without errors.

1. Use the Collector internal metrics on port 8888 to compare the number of spans the receiver accepted with the number the exporter sent.
2. Find the processor that drops the spans and fix its condition so that only spans named `GET /healthz` are dropped and all other spans are exported.
3. Keep the filter processor in the pipeline.

`kubectl` already points at the cluster. The configuration is the key `config.yaml` of the ConfigMap `otelcol-config`. Restart the Deployment after a change. The `shuttle` pod in `starfleet` has `curl`.
