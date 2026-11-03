# Question

Solve this question on: `terminal`

The Collector `otelcol` in the `observability` namespace receives spans over OTLP/HTTP and exports them to the Collector `backend` in the same namespace, which writes every accepted span to its log. Spans sent to `otelcol` get status 200, but none of them appears in the log of the `backend`.

1. Find out why the data is lost. Read the log of `otelcol` for the line that says the data is dropped, and read the status code and the URL in the error.
2. Fix the exporter `otlp_http/backend` in the ConfigMap `otelcol-config` so that new spans reach the `backend`.
3. Keep the exporter, the `debug` exporter and the traces pipeline. Do not change the `backend` or its image.

`kubectl` already points at the cluster. The Collector reads its configuration at start, so restart the Deployment `otelcol` after a change. The `shuttle` pod in `starfleet` has `curl`.
