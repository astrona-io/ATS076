# Question

Solve this question on: `terminal`

The Collector `otelcol` in `observability` receives traces over OTLP/HTTP and exports them with an `otlp_http/backend` exporter to the `backend` Service in the same namespace, and with the `debug` exporter. Today the exporter has `retry_on_failure` and `sending_queue` switched off. When the `backend` restarts, spans that arrive in that time are lost.

1. Switch on `retry_on_failure` for `otlp_http/backend`.
2. Switch on `sending_queue` for `otlp_http/backend` and set its `queue_size` to `5000` batches.
3. Keep the `debug` exporter and the receiver as they are.

A span that the Collector accepts while the `backend` is down must reach the `backend` after it is back. The check scales the `backend` Deployment to zero for a short time, then back to one. `kubectl` already points at the cluster. The configuration is the key `config.yaml` of the ConfigMap `otelcol-config`; restart the Deployment `otelcol` after a change. The `shuttle` pod in `starfleet` has `curl`.
