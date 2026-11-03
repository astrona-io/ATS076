# Question

Solve this question on: `terminal`

A Collector in the `observability` namespace (Deployment `otelcol`, Service `otelcol`) must receive traces from applications over OTLP/HTTP on port 4318 and print them with the `debug` exporter. The `scout` team reports that their exports fail with a connection error. Applications in `starfleet` use `http://otelcol.observability:4318/v1/traces`.

1. Find out why nothing listens on port 4318 although the configuration defines an OTLP/HTTP receiver.
2. Change the configuration so that the Collector accepts spans over OTLP/HTTP and prints them with the `debug` exporter.
3. Keep the OTLP/gRPC receiver and the health check extension working.

`kubectl` already points at the cluster. The configuration is the key `config.yaml` of the ConfigMap `otelcol-config`. The Collector reads it at start, so restart the Deployment after a change. The `shuttle` pod in `starfleet` has `curl`.
