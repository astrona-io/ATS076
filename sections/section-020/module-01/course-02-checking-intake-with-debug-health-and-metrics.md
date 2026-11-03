---
draft: true
exam_objectives:
  - Debugging Pipelines
---
# Checking Intake With Debug, Health And Metrics

A pipeline can be wrong in many ways, and the symptom is usually the same: the backend shows nothing. Before you change a configuration, you need evidence of what the Collector accepts and what it does with it. This part introduces three sources of evidence that the Collector provides about itself, and a way to send a test span so that you know exactly which data to look for.

## Three sources of evidence

The Collector reports on itself in three ways:

- **The debug exporter** prints the telemetry that reaches it. It shows what data arrives at the end of a pipeline.
- **The health check extension** answers HTTP requests on a port. It shows that the process is up and that the extension is enabled.
- **The internal telemetry** is a set of metrics about the Collector's own work, such as the number of spans accepted by receivers and sent by exporters.

The Collector log is a fourth source. It records start-up, configuration errors and export failures.

## The debug exporter

The `debug` exporter writes telemetry to the Collector log. Its `verbosity` setting selects how much:

| Value | What is printed |
| --- | --- |
| `basic` | One line per batch with the number of items. |
| `normal` | A short line per item. |
| `detailed` | All fields of each item, including attributes. |

The text format is meant for people and the project does not promise it stays the same between versions. Use it to look at data, not to build automation that depends on exact text.

A pipeline that has the `debug` exporter next to the real exporter shows what the real exporter will receive. With `detailed` verbosity, a span appears with its trace ID, span ID, name and attributes. That is enough to find a test span by its trace ID.

Debug output has a cost: in a production pipeline with high volume, `detailed` writes a large amount of text. Use it while you debug, and set it back to `basic` or remove it afterwards.

## The health check extension

The `health_check` extension serves a status endpoint. With this configuration it listens on all interfaces of the pod:

```yaml
extensions:
  health_check:
    endpoint: 0.0.0.0:13133
service:
  extensions: [health_check]
```

A request to port 13133 returns a status code. A `200` means the Collector process runs and the extension runs. It does not mean that receivers accept data or that exporters reach their destinations: the extension reports on the process, not on each pipeline. Kubernetes probes often use this endpoint to decide whether to restart a pod.

If a request to the port fails to connect, either the extension is not in `service.extensions`, or the endpoint binds to another address, or the process is not running.

## Internal telemetry and the 8888 endpoint

The Collector exposes metrics about itself. In the configuration used in this course, the `service.telemetry` section starts a pull reader that serves metrics in Prometheus text format on port 8888:

```yaml
service:
  telemetry:
    metrics:
      level: normal
      readers:
        - pull:
            exporter:
              prometheus:
                host: 0.0.0.0
                port: 8888
```

A request to `/metrics` on that port returns one line per metric and label set. The metric names that matter for intake are:

- `otelcol_receiver_accepted_spans`: spans that a receiver accepted and passed on.
- `otelcol_receiver_refused_spans`: spans that a receiver rejected, for example because of memory limits.
- `otelcol_exporter_sent_spans`: spans that an exporter sent successfully.
- `otelcol_exporter_send_failed_spans`: spans that an exporter could not send.

Depending on the Collector version, counter names may end in `_total`. Search with the part of the name that does not change. The default port, the settings and the metric names depend on the version, so check the version you run.

A receiver that does not run does not appear at all. A missing metric for a receiver is evidence that the receiver is not part of a pipeline.

## Send a test span

To find a test item in debug output, you need to know its identity. An OTLP/HTTP request with a JSON body is easy to build by hand. It needs a trace ID of 32 hex characters and a span ID of 16 hex characters. This request sends one span named `checkout-test`:

<!-- astrona:playground:renew -->

```sh
kubectl -n starfleet exec deploy/shuttle -- curl -s -o /dev/null -w '%{http_code}\n' -X POST -H 'Content-Type: application/json' -d '{"resourceSpans":[{"resource":{},"scopeSpans":[{"scope":{},"spans":[{"traceId":"5b8efff798038103d269b633813fc60c","spanId":"eee19b7ec3c1b174","name":"checkout-test","kind":2,"startTimeUnixNano":"1700000000000000000","endTimeUnixNano":"1700000001000000000"}]}]}]}' http://otelcol.observability:4318/v1/traces
```

The command prints only the HTTP status code. A `200` means the receiver accepted the request. A `000` means curl could not connect. In the playground the Collector starts with the receiver `otlp/http` defined but not in the pipeline, so you should see `000` first.

Read the Collector log to see whether the span reached the exporter:

```sh
kubectl -n observability logs deploy/otelcol --tail=50
```

Search the text for the trace ID `5b8efff798038103d269b633813fc60c`. If it is there, the span passed every stage up to the `debug` exporter.

Read the internal metrics:

```sh
kubectl -n starfleet exec deploy/shuttle -- curl -s http://otelcol.observability:8888/metrics
```

The output is long. Pick the lines that start with `otelcol_receiver_accepted_spans` and `otelcol_exporter_sent_spans` and compare them after each test span.

## Reading the evidence together

Each source answers one question. Together they locate the fault:

| Observation | What it shows |
| --- | --- |
| Connection refused on port 4318 | No receiver listens on it. Check the pipelines. |
| Status `200`, accepted counter grows, trace ID not in debug output | Data is lost between the receiver and the debug exporter, in a processor. |
| Status `200`, trace ID in debug output, backend empty | The fault is in the exporter to the backend or in the backend. |
| Health check refused | The extension is not enabled or the process is not running. |

## Restart after a change

The Collector reads its configuration at start. If the file comes from a ConfigMap mounted into the pod, an edit changes the file but not the running process. Restart the Deployment:

```sh
kubectl -n observability rollout restart deployment/otelcol
kubectl -n observability rollout status deployment/otelcol
```

Then repeat the test span. The same request with the same trace ID is a fair test only when the earlier result is not mixed in; use a new trace ID for each test so that you do not mistake an old log line for a new one.

## Checkpoints

- A request to port 4318 returns `200`, and the test trace ID is not in the debug output. Where is the fault?
- The health check returns `200` and the backend is empty. Does the health check prove that exports work?
- Why use a new trace ID for each test?

Answers: between the receiver and the debug exporter, which means a processor. No: it shows that the process runs, not that a pipeline delivers. An old trace ID in the log can be mistaken for the result of the new test.

You can now collect evidence from the Collector itself and place a fault at intake, in processing or at export. The next step is to learn which signals show data loss between stages.

## Common pitfalls

> [!WARNING]
> - Do not leave `verbosity: detailed` on in a busy production pipeline.
> - Do not treat a `200` from the health check as proof that data reaches the backend.
> - Do not reuse a trace ID between tests. Old log lines look like new results.
> - Do not build automation on the exact text of the debug exporter. The format can change.
