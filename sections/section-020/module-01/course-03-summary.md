---
draft: true
exam_objectives:
  - Debugging Pipelines
---
# Summary

A Collector configuration has sections that define components and a `service` section that selects which ones run. Receivers, processors, exporters, connectors and extensions only describe components. A component starts when a pipeline or the list of extensions names it. A defined component that nothing names is valid and does not run, so the Collector reports no error.

A pipeline connects receivers to exporters through processors that run in the listed order. Several receivers feed the same first processor, and every exporter receives its own copy of the output. Fault location follows from this order: a refused connection points at receivers, data lost after acceptance points at processors, and data that reaches the last stage points at exporters.

The Collector supplies its own evidence. The debug exporter prints the items that reach it, the health check extension shows that the process and the extension run, and the internal metrics on port 8888 count accepted and sent spans. A test span with a known trace ID, sent over OTLP/HTTP, shows how far data travels. The Collector reads its configuration at start, so every change needs a restart.

Key facts:

- Defined components do not run until the `service` section names them.
- `validate` accepts unused components.
- A `200` from the health check does not show that a pipeline delivers.
- Use a new trace ID for every test.

<!-- astrona:playground:destroy -->
