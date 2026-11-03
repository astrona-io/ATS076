# Processors That Drop Data

This playground starts a kind cluster (Kubernetes 1.35) and applies the example workloads. It was built without being booted.

## What is running

A Collector with a `filter/health` processor whose condition drops every span except the health check.

The `shuttle` pod in `starfleet` has `curl`. The Collector configuration is the key `config.yaml` of the ConfigMap `otelcol-config` in `observability` (nginx configurations are in ConfigMaps named `<proxy>-conf` in `starfleet`). Collectors and proxies read their configuration at start, so restart the Deployment after an edit.

## Things to try

- Send a `POST /checkout` span and a `GET /healthz` span and watch which one the `debug` exporter prints.
- Compare the receiver accepted counter and the processor and exporter counters on port 8888.
- Change the condition, restart, and repeat the two requests.

Nothing here is graded.
