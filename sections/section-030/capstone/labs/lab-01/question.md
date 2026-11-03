# Question

Solve this question on: `terminal`

The Collector `otelcol` in `observability` receives traces over OTLP/HTTP and exports them to the `backend` Service with the exporter `otlp_http/backend` (and prints them with `debug`). It runs with a container memory limit of `256Mi`. A volume is mounted at `/var/lib/otelcol`, and the extension `file_storage/queue` is defined but not used. The pipeline can lose telemetry in three ways.

1. Make the `memory_limiter` the first processor of the traces pipeline (flow style, one line) and set `limit_mib` to at most `200` with `spike_limit_mib` below it.
2. Switch on `retry_on_failure` and `sending_queue` for `otlp_http/backend`, set `queue_size` to `5000`, and store the queue with the extension `file_storage/queue` (`storage: file_storage/queue`). Add the extension to `service.extensions` in flow style, for example `[health_check, file_storage/queue]`.
3. A span that the Collector accepts while the `backend` is down must reach the `backend` after it is back. The check scales the `backend` Deployment to zero for a short time, then back to one.
4. Record the evidence in a ConfigMap `loss-evidence` in `observability` with these keys:
   - `retry`, `queue` and `memory`: one line each that says what you configured.
   - `observed-at`: the time of your last check in UTC, in the form `2026-11-03T10:15:00Z`.

`kubectl` already points at the cluster. The configuration is the key `config.yaml` of the ConfigMap `otelcol-config`; restart the Deployment `otelcol` after a change.
