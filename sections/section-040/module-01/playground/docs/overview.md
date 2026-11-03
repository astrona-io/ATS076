# Renaming Attributes With OTTL

This playground starts a kind cluster (Kubernetes 1.35) and applies the example workloads. It was built without being booted.

## What is running

A Collector with no processor, and spans that use legacy HTTP attribute names.

The `shuttle` pod in `starfleet` has `curl`. The Collector configuration is the key `config.yaml` of the ConfigMap `otelcol-config` in `observability` (nginx configurations are in ConfigMaps named `<proxy>-conf` in `starfleet`). Collectors and proxies read their configuration at start, so restart the Deployment after an edit.

## Things to try

- Send a span with `http.method` and read the attribute list in the `debug` output.
- Add a `transform/semconv` processor that copies the value to `http.request.method` and deletes the old name.
- Remove the `where` clause and send a span that already uses the new name. Read what happened to its value.

Nothing here is graded.
