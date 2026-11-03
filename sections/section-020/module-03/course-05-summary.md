---
draft: true
exam_objectives:
  - Debugging Pipelines
---
# Summary

An extension is a Collector component that adds a capability and does not handle telemetry data. It is defined in the `extensions` section and starts only when it is listed in `service.extensions`. A defined extension that is not listed never runs, and nothing in the configuration check says so.

Many extensions open a port, and the host part of the endpoint decides who can connect. A `localhost` binding accepts connections only from inside the pod. A `0.0.0.0` binding accepts them from other pods and from a Service. The command `kubectl port-forward` reaches a `localhost` binding, because it connects inside the network namespace of the pod.

The `zpages` extension serves pages about the running process. The `pipelinez` page lists the running pipelines and the `extensionz` page lists the running extensions, so you can compare the live process with the file. The `pprof` extension serves Go profiles of CPU, memory and goroutines. The `health_check` extension answers 200 when the process runs, and it does not prove that data flows.

Each diagnostic tool answers one kind of question. The health check, the log and zPages describe the Collector. The internal metrics count the data. The `debug` exporter shows the content of the data. pprof shows the resources of the process. A good investigation goes from cheap and broad tools to expensive and narrow ones.

Key facts:

- `zpages` defaults to `localhost:55679`, `pprof` to `localhost:1777` and `health_check` to port 13133.
- A diagnostic port that is public exposes internal details.
- Raise the log, metric and exporter detail only while you investigate.

<!-- astrona:playground:destroy -->
