# Trace Context Through A Gateway

This playground starts a kind cluster (Kubernetes 1.35) and applies the example workloads. It was built without being booted.

## What is running

A `shuttle` pod, a `probe` that echoes request headers, and a `gateway` nginx proxy that removes `traceparent` and `tracestate`.

The `shuttle` pod in `starfleet` has `curl`. The Collector configuration is the key `config.yaml` of the ConfigMap `otelcol-config` in `observability` (nginx configurations are in ConfigMaps named `<proxy>-conf` in `starfleet`). Collectors and proxies read their configuration at start, so restart the Deployment after an edit.

## Things to try

- Send a request with a `traceparent` header straight to `probe` and read the echo: `kubectl -n starfleet exec deploy/shuttle -- curl -s http://probe.starfleet/headers -H 'traceparent: 00-0af7651916cd43dd8448eb211c80319c-b7ad6b7169203331-01'`.
- Send the same request through `gateway.starfleet` and compare the two echoes.
- Edit the ConfigMap `gateway-conf`, restart the Deployment `gateway`, and repeat.
- Add a `proxy_set_header` line that sets `tracestate` to a fixed value and watch what the probe receives.

Nothing here is graded.
