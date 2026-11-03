# Dual Emission During A Migration

This playground starts a kind cluster (Kubernetes 1.35) and applies the example workloads. It was built without being booted.

## What is running

A Collector that renames legacy HTTP attributes and deletes the old names.

The `shuttle` pod in `starfleet` has `curl`. The Collector configuration is the key `config.yaml` of the ConfigMap `otelcol-config` in `observability` (nginx configurations are in ConfigMaps named `<proxy>-conf` in `starfleet`). Collectors and proxies read their configuration at start, so restart the Deployment after an edit.

## Things to try

- Send a legacy span and a new-style span and read both attribute lists.
- Replace the deletes with copies in both directions and compare the output.
- Add a statement that sets a `schema.version` marker attribute and read it in the output.

Nothing here is graded.
