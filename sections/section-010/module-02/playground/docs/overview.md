# Baggage At A Trust Boundary

This playground starts a kind cluster (Kubernetes 1.35) and applies the example workloads. It was built without being booted.

## What is running

A `shuttle` pod, a `probe` that echoes request headers, and an `edge` nginx proxy with a public listener on port 80 and an internal listener on port 8081.

The `shuttle` pod in `starfleet` has `curl`. The Collector configuration is the key `config.yaml` of the ConfigMap `otelcol-config` in `observability` (nginx configurations are in ConfigMaps named `<proxy>-conf` in `starfleet`). Collectors and proxies read their configuration at start, so restart the Deployment after an edit.

## Things to try

- Send `traceparent` and `baggage` headers to both listeners and compare what the probe receives.
- Edit the ConfigMap `edge-conf` to remove `baggage` on one listener only, then restart the Deployment `edge`.
- Try an upstream header that is not in the request and see whether nginx adds it.

Nothing here is graded.
