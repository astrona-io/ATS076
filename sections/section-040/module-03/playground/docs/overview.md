# Schema Files And Transformations

This playground starts a kind cluster (Kubernetes 1.35) and applies the example workloads. It was built without being booted.

## What is running

A `shuttle` pod with `curl` in `starfleet`. In `observability`, a Collector `otelcol` receives OTLP/HTTP on port 4318 and prints every span with the `debug` exporter at `detailed` verbosity. In `starfleet`, the ConfigMap `schema-file` holds a schema file in the key `schema.yaml`. The file has mistakes.

## Things to try

- Print the schema file and run the checklist from the module with `grep`.
- Send a span with a resource-level and a scope-level schema URL and find both in the log of `otelcol`.
- Fix the file with `kubectl edit configmap schema-file -n starfleet`.
- Write the OTTL statements that perform the rename `ship.name` to `starship.name`.

Nothing here is graded.
