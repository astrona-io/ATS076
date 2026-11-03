---
draft: true
exam_objectives:
  - Error Handling
---
# Retryable And Permanent Errors

When an export fails, the sender must decide between two actions. It can wait and send the same data again, or it can drop the data. Retrying a request that can never succeed wastes resources and blocks the queue. Dropping a request that would have succeeded loses telemetry. The OTLP specification gives a fixed list of which errors fall in which group. This part gives that list for both transports.

## The rule behind the list

An error is retryable when the same request may succeed later without a change. An error is permanent when the request is wrong, or the destination refuses it for a reason that waiting does not change.

A temporary overload or a restart is retryable. An unknown path, malformed data or a missing permission is permanent.

## HTTP status codes

For OTLP/HTTP, a sender retries only these status codes:

| Status | Meaning | Action |
| --- | --- | --- |
| 429 | Too Many Requests | Retry |
| 502 | Bad Gateway | Retry |
| 503 | Service Unavailable | Retry |
| 504 | Gateway Timeout | Retry |

All other 4xx and 5xx status codes are permanent. The sender must not retry them. This includes 400 (the data is invalid), 401 and 403 (authentication or permission), 404 (wrong path) and 500 (a server error the specification does not mark as temporary).

The same is true for a connection that cannot be opened at all. A refused connection or a timeout before a response is a transport failure, and the Collector treats it as retryable.

## gRPC status codes

For OTLP/gRPC, a sender retries these status codes:

- `CANCELLED`
- `DEADLINE_EXCEEDED`
- `ABORTED`
- `OUT_OF_RANGE`
- `UNAVAILABLE`
- `DATA_LOSS`

The status `RESOURCE_EXHAUSTED` is retryable only when the server includes a `RetryInfo` detail in the error. `RetryInfo` tells the client how long to wait. Without it, `RESOURCE_EXHAUSTED` is permanent.

Other gRPC statuses are permanent. These include `INVALID_ARGUMENT`, `NOT_FOUND`, `UNAUTHENTICATED` and `PERMISSION_DENIED`.

## What a permanent error means in the Collector

The Collector exporter helper wraps the retry logic for every exporter. When a request fails with a permanent error, the helper does not wait. It logs that the data is dropped and counts the items as failed. When the error is retryable and `retry_on_failure` is enabled, it waits and tries again until `max_elapsed_time` has passed.

So a permanent error is visible in two places at once. The log shows an error that says the export failed and the data was dropped, together with the status code. The counter `otelcol_exporter_send_failed_spans` for that exporter increases by the number of spans in the request.

## Receivers choose the status they return

The same rules apply in the other direction. A Collector OTLP receiver answers the sender. It returns a retryable status when the cause is temporary and a permanent one when the data is wrong.

- Data that cannot be decoded gets 400 over HTTP, or `INVALID_ARGUMENT` over gRPC. The sender drops it.
- A refusal because the pipeline cannot take more data, for example from the memory limiter, is a temporary condition. The receiver answers 503 over HTTP, or `UNAVAILABLE` over gRPC. The sender keeps the data and tries again.

This is the link to the memory limiter: the limiter relies on the sender to retry. A sender that treats 503 as permanent would lose data every time the Collector is under pressure.

## Compare the three answers

In the playground, send one valid request, one request to a wrong path and one malformed request to the first Collector, as in the previous part. The statuses are 200, 404 and 400. Only the first one is a success. The other two are permanent, so an exporter that received them would not retry. Save the three commands, because the same checks are useful when you test a new endpoint.

<!-- astrona:playground:renew -->

```sh
kubectl -n starfleet exec deploy/shuttle -- curl -s -o /dev/null -w '%{http_code}\n' -X POST -H 'Content-Type: application/json' -d '{not json' http://otelcol.observability:4318/v1/traces
```

The status 400 tells the sender that the request is wrong. No wait can fix it. A sender that sees only the logs of this call, "bad request", can stop investigating the network and look at the encoding.

## Checkpoints

- Which HTTP status codes does a sender retry?
- A sender receives 404 from the destination. Does it retry?
- When is `RESOURCE_EXHAUSTED` retryable?

Answers: 429, 502, 503 and 504. No, because 404 is permanent. Only when the server sends `RetryInfo`.

You now know which answers keep data in the queue and which remove it. The next part covers a case that fits neither group: the server accepts the request but keeps only some of the items.

## Common pitfalls

> [!WARNING]
> - Do not enable retries to fix a 4xx error. The status is permanent, and retries are never sent.
> - Do not treat all 5xx statuses as retryable. Only 502, 503 and 504 are.
> - Do not assume a refused connection is permanent. It is retried like a 503.
