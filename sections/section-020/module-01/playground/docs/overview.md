# Receivers And Pipelines

This playground starts a kind cluster (Kubernetes 1.35) and applies the example workloads. It was built without being booted.

## What is running

A Collector with an OTLP/gRPC and an OTLP/HTTP receiver where only the gRPC receiver is in the traces pipeline.

The `shuttle` pod in `starfleet` has `curl`. The Collector configuration is the key `config.yaml` of the ConfigMap `otelcol-config` in `observability` (nginx configurations are in ConfigMaps named `<proxy>-conf` in `starfleet`). Collectors and proxies read their configuration at start, so restart the Deployment after an edit.

## Things to try

- Post an OTLP/JSON span to port 4318 and read the connection error.
- Read the log with `kubectl -n observability logs deploy/otelcol` and find the line that lists the started components.
- Add the receiver to the pipeline, restart, and read the `debug` exporter output for a span you send.
- Read `http://otelcol.observability:8888/metrics` and find `otelcol_receiver_accepted_spans`.

Nothing here is graded.
