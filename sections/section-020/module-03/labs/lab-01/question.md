# Question

Solve this question on: `terminal`

The Collector `otelcol` in the `observability` namespace defines the `zpages` and `pprof` extensions. A request from the `shuttle` pod in `starfleet` to `http://otelcol.observability:55679/debug/pipelinez` or to `http://otelcol.observability:1777/debug/pprof/` fails.

1. Find out why the two pages cannot be reached. Check the Collector log, the list `service.extensions` and the endpoints of the extensions.
2. Change the configuration so that both pages answer with status 200 to a request from the `shuttle` pod.
3. Keep the health check, the traces pipeline and the `debug` exporter working. Do not delete the Collector or change its image.

`kubectl` already points at the cluster. The configuration is in the ConfigMap `otelcol-config` in `observability`. The Collector reads its configuration at start, so it must restart after a change.
