# OTLP Responses And Retry Semantics

This playground starts a kind cluster (Kubernetes 1.35) and applies the example workloads. It was built without being booted.

## What is running

A `shuttle` pod with `curl` in `starfleet`. In `observability`, a Collector `otelcol` receives spans over OTLP/HTTP on port 4318 and exports them with the exporter `otlp_http/backend` to a second Collector named `backend`, which writes every span it accepts to its log. The exporter `endpoint` holds a path, which causes a permanent error.

The configuration of each Collector is the key `config.yaml` of the ConfigMaps `otelcol-config` and `backend-config`. Collectors read their configuration at start, so restart the Deployment after an edit.

## Things to try

- Send a span to `http://otelcol.observability:4318/v1/traces` and read the status.
- Read the log of `otelcol` for the drop line and the status code in it.
- Read `otelcol_exporter_send_failed_spans` on port 8888.
- Send a malformed body and a request to a wrong path and compare the statuses.
- Fix the endpoint, restart, and watch the span arrive in the log of `backend`.

Nothing here is graded.
