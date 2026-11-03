# The Memory Limiter

This playground starts a kind cluster (Kubernetes 1.35) and applies the example workloads. It was built without being booted.

## What is running

A Collector with a `memory_limiter` that is last in the pipeline and has a limit larger than its 256Mi container.

The `shuttle` pod in `starfleet` has `curl`. The Collector configuration is the key `config.yaml` of the ConfigMap `otelcol-config` in `observability` (nginx configurations are in ConfigMaps named `<proxy>-conf` in `starfleet`). Collectors and proxies read their configuration at start, so restart the Deployment after an edit.

## Things to try

- Read the processors list and the limits and decide what the limiter can protect today.
- Move the limiter first, set a limit that fits, restart, and read the log line that prints the limiter settings.
- Read `kubectl -n observability get pod -l app=otelcol -o yaml` and find the container memory limit.

Nothing here is graded.
