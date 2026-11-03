# Collector Diagnostic Extensions

This playground starts a kind cluster (Kubernetes 1.35) and applies the example workloads. It was built without being booted.

## What is running

A `shuttle` pod with `curl` in `starfleet`, and a Collector in `observability` (Service `otelcol`). The Collector configuration is the key `config.yaml` of the ConfigMap `otelcol-config`. It defines the extensions `health_check`, `zpages` and `pprof`, but lists only `health_check` in `service.extensions`. The `zpages` and `pprof` endpoints are bound to `localhost`.

The Collector reads its configuration at start, so restart the Deployment after an edit: `kubectl -n observability rollout restart deployment/otelcol`.

## Things to try

- Read the Collector log and look for the extensions that start.
- Request `http://otelcol.observability:55679/debug/pipelinez` from the `shuttle` pod and note the failure.
- Add `zpages` to `service.extensions`, restart, and use `kubectl port-forward` to read the page while the endpoint is still bound to `localhost`.
- Change the endpoint to `0.0.0.0:55679` and request the page from the `shuttle` pod.
- Take a heap profile through the `pprof` port.

Nothing here is graded.
