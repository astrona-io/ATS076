# Retry And The Sending Queue

This playground starts a kind cluster (Kubernetes 1.35) and applies the example workloads. It was built without being booted.

## What is running

A Collector that exports to a `backend` Collector, with `retry_on_failure` and `sending_queue` switched off.

The `shuttle` pod in `starfleet` has `curl`. The Collector configuration is the key `config.yaml` of the ConfigMap `otelcol-config` in `observability` (nginx configurations are in ConfigMaps named `<proxy>-conf` in `starfleet`). Collectors and proxies read their configuration at start, so restart the Deployment after an edit.

## Things to try

- Scale the backend to zero (`kubectl -n observability scale deploy/backend --replicas=0`), send a span, scale it back, and read the backend log.
- Switch on `retry_on_failure` and `sending_queue`, restart the Collector, and repeat the outage.
- Read `otelcol_exporter_queue_size` and `otelcol_exporter_queue_capacity` on port 8888 during the outage.
- Set `queue_size` to a very small number and send many spans during the outage.

Nothing here is graded.
