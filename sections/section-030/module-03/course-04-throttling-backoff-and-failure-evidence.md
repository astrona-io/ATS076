---
draft: true
exam_objectives:
  - Error Handling
---
# Throttling, Backoff And Failure Evidence

A retryable error does not mean that the sender should retry at once. A server that is overloaded needs time. If every sender retries immediately, the load rises and the server falls further behind. This part explains how a server asks senders to wait, how the Collector spaces its retries and how to read the evidence when an export fails for good.

## The server can ask for a wait

When a server cannot take more data now, it answers with a retryable status and may add how long the sender should wait.

- Over HTTP, the server adds the header `Retry-After` to a 429 or 503 response.
- Over gRPC, the server adds a `RetryInfo` detail to the error. The detail holds a delay.

A sender that supports this waits at least as long as the server asked. If the server gives no value, the sender uses its own backoff.

## Exponential backoff with jitter

Backoff is a delay that grows with each failed attempt. The Collector exporter helper uses exponential backoff with these settings in `retry_on_failure`:

- `initial_interval`: the wait after the first failure. The default is 5 seconds.
- `multiplier`: the factor by which the wait grows. The default is 1.5.
- `max_interval`: the longest single wait. The default is 30 seconds.
- `max_elapsed_time`: the total time after which the sender gives up and drops the data. The default is 5 minutes.
- `randomization_factor`: a random spread added to each wait. The spread is the jitter. It stops many senders from retrying at the same moment.

A value of `0` for `max_elapsed_time` means that the sender never gives up. A batch then stays in the queue as long as the error lasts and may block newer batches. Set a bound that matches how long the data is useful.

## Two logs that look similar and are not

The exporter log contains two kinds of failure lines. They mean different things.

- A line that says the export failed and that the request will be retried after an interval. The error is retryable. The log line includes the interval and the error text. No data is lost yet.
- A line that says the export failed and that the data is dropped. The error is permanent, or the retries ran out. The data is lost.

Read the second kind first. It marks a loss. Its error text carries the reason: the status code and the URL for HTTP, or the gRPC status.

## The counters

Three internal metrics tell the same story in numbers:

- `otelcol_exporter_sent_spans`: spans the exporter sent successfully.
- `otelcol_exporter_send_failed_spans`: spans the exporter failed to send. A permanent error adds the whole request at once.
- `otelcol_exporter_enqueue_failed_spans`: spans that the queue refused because it was full.

Metrics and logs exist for the other signals with the names `metric_points` and `log_records` instead of `spans`. Which counter rises tells you which stage failed. A rising `send_failed` with a 404 in the log means a wrong endpoint path. A rising `enqueue_failed` means the queue is too small for the rate.

## Diagnose a permanent error on a live exporter

In the playground, the first Collector exports to the `backend` Collector, and spans do not arrive. Send one span and then read the log of the first Collector:

<!-- astrona:playground:renew -->

```sh
kubectl -n starfleet exec deploy/shuttle -- curl -s -o /dev/null -w '%{http_code}\n' -X POST -H 'Content-Type: application/json' -d '{"resourceSpans":[{"resource":{"attributes":[{"key":"service.name","value":{"stringValue":"scout"}}]},"scopeSpans":[{"scope":{"name":"lab"},"spans":[{"traceId":"5b8efff798038103d269b633813fc60c","spanId":"eee19b7ec3c1b174","name":"permanent-demo","kind":2,"startTimeUnixNano":"1700000000000000000","endTimeUnixNano":"1700000001000000000"}]}]}]}' http://otelcol.observability:4318/v1/traces
```

The status is 200, because the first Collector accepted the span. The failure happens later, in the exporter.

```sh
kubectl -n observability logs deploy/otelcol --tail=50
```

Look for the line that says the data was dropped. Its error text names the status code that the destination answered and the URL that the exporter used. A URL that contains `/v1/traces/v1/traces` shows the double path from the first part. Then read the counter:

```sh
kubectl -n starfleet exec deploy/shuttle -- curl -s http://otelcol.observability:8888/metrics
```

Find the line `otelcol_exporter_send_failed_spans` for the exporter `otlp_http/backend`. Its value is greater than zero after the failed request. The sender accepted the span and the destination refused it, so the span is lost and no retry happens.

## Fix and prove

The fix is to correct the `endpoint` to the base URL, restart the Collector and send a new span. Prove it with three observations: the new span name appears in the log of the `backend`, the exporter log shows no new drop line, and the failed counter, which restarts from zero with the process, stays at zero.

## Checkpoints

- A destination answers 503 with `Retry-After`. What should the sender do?
- What does `max_elapsed_time: 0s` mean?
- A 404 appears in an exporter drop line. Does enabling `retry_on_failure` help?

Answers: wait at least the time in the header, then retry. The sender never gives up, so a batch can stay in the queue as long as the error lasts. No, because 404 is permanent.

You can now sort an export failure into retryable, permanent and partial, and you know which log line and which counter prove it.

## Common pitfalls

> [!WARNING]
> - Do not set `max_elapsed_time` to `0s` without a plan for a full queue.
> - Do not read a 200 at the first Collector as proof that the data reached the backend.
> - Do not compare counters from before and after a restart. They start again from zero.
