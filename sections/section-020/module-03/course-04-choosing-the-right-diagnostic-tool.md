---
draft: true
exam_objectives:
  - Debugging Pipelines
---
# Choosing The Right Diagnostic Tool

The Collector has more than one diagnostic tool, and each tool answers one kind of question. A learner who reaches for the wrong tool wastes time or draws a wrong conclusion. This part lists the tools, the question each one answers and a simple order of use.

## The tools in one place

There are six sources of evidence in a Collector:

1. **The health check** answers whether the process is up.
2. **The Collector log** shows startup, configuration errors and component warnings. You set its level with `service.telemetry.logs.level`, for example `debug`.
3. **Internal metrics** are counters and gauges about the Collector itself. They are served on the port that `service.telemetry.metrics` configures, in this course port 8888. The metric level `basic`, `normal` or `detailed` sets how many metrics exist.
4. **The `debug` exporter** writes the telemetry that reaches it to the log of the Collector. Its `verbosity` setting is `basic`, `normal` or `detailed`.
5. **zPages** shows the running structure: pipelines, extensions and the Collector's own spans.
6. **pprof** shows where the process spends CPU and memory.

## Which tool for which question

| Question | Tool |
| --- | --- |
| Is the Collector process running? | Health check |
| Did the configuration load, and which component failed to start? | Collector log |
| Does the running pipeline match the file? | zPages `pipelinez` and `extensionz` |
| How many items did a receiver accept, and how many did an exporter send or fail to send? | Internal metrics |
| What does the data look like after a processor? | `debug` exporter with `detailed` verbosity |
| Why does the process use so much memory or CPU? | pprof |

The table has a pattern. The health check, the log and zPages describe the Collector. The metrics count the data. The `debug` exporter shows the content of the data. pprof shows the resources of the process.

## A fixed order for a missing-data problem

When a backend does not show data that an application sent, work in this order.

1. Check the health check. If the Collector does not answer, stop and read the log for a start-up error.
2. Read the Collector log for the configuration and for errors from exporters.
3. Compare the running pipelines with the file on `pipelinez`.
4. Compare the counters of the receiver and the exporter. The difference between accepted and sent items is the number the processors dropped or the exporters failed to send.
5. Add a `debug` exporter after the processor that you suspect and read the content.
6. Only if memory or CPU is the symptom, take a profile.

The order goes from cheap and broad to expensive and narrow. Each step either finds the fault or shrinks the place where you must look.

## Run the order in the playground

In the playground, the Collector has the three extensions defined and a fault in how they are exposed. Start with the log, which shows the extensions that started:

<!-- astrona:playground:renew -->

```sh
kubectl -n observability logs deploy/otelcol
```

Read the log from the top. Each extension that starts writes a line, and a missing line for `zpages` or `pprof` is the first evidence. Then check the running list on the page, and compare it with the list in the ConfigMap:

```sh
kubectl -n observability get configmap otelcol-config -o jsonpath='{.data.config\.yaml}'
```

Compare `service.extensions` with the keys under `extensions`. A key that is not in the list does not run. For a key that is in the list, read the host part of its `endpoint`. A `localhost` binding explains a connection that is refused from another pod while a port-forward still works.

## Set log and metric levels with care

Raising the log level to `debug` and the metric level to `detailed` helps during a fault. It costs CPU, memory and log volume. Set them while you investigate and set them back afterwards. The `debug` exporter has the same cost with `detailed` verbosity on a busy pipeline, so use it on a test pipeline or with a sampling filter in front of it.

## Checkpoints

- Which tool shows the attributes of a span after a processor changed them?
- Which tool answers whether an extension that you configured is running?
- Why does the order of use start with the health check and the log?

Answers: the `debug` exporter with `detailed` verbosity. The log and `extensionz` on zPages. They are cheap and broad, and they find start-up faults before you read details.

You now have a tool for each question and an order of use. The lab of this module puts them together on a Collector whose diagnostic extensions are defined but not reachable.

## Common pitfalls

> [!WARNING]
> - Do not leave `debug` log level and `detailed` metrics on after the investigation.
> - Do not skip the log. A configuration error is often written there on the first line.
> - Do not take a profile before the cheaper tools have said that the problem is memory or CPU.
