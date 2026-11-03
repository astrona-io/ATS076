---
draft: true
exam_objectives:
  - Error Handling
---
# Partial Success And Rejected Items

Not every failure is a failed request. A backend can accept a request and still refuse some of the spans, metric points or log records in it. For example, a span may have an attribute value that is too large, or a metric may be missing a required field. If the server answered with a plain error, the sender would retry the whole batch and the same items would fail again. OTLP has a separate answer for this case. This part explains it.

## The partial success response

The response message of every OTLP export has an optional field named `partial_success`. A server sets it when it accepted the request, but could not keep every item. The message has two fields.

- `rejected_spans`, `rejected_data_points` or `rejected_log_records`: the number of items the server did not accept. The name depends on the signal.
- `error_message`: a human-readable text that says why.

The transport status is still success: HTTP 200, or gRPC `OK`. The partial success is inside the body.

```json
{
  "partialSuccess": {
    "rejectedSpans": 3,
    "errorMessage": "attribute value too long"
  }
}
```

## What the sender must do

The specification is clear: the sender must not retry a request that got a partial success. The rejected items would be rejected again, and the accepted items would be stored twice.

The sender should log the `error_message` and may count the rejected items. In the Collector exporters, the partial success is logged as a warning, and the data is not queued again.

A rejected count of zero with a non-empty `error_message` is also allowed. It is a warning: the server stored everything but wants the sender to know about a problem, for example a deprecated field.

## Why this matters for debugging

A partial success is the one kind of data loss that no status code shows. A pipeline can have a transport success rate of 100 percent, no failed counters and still lose spans.

The evidence is in three places.

- The log of the exporter, which writes the `error_message`.
- The log or the metrics of the destination, which often count the rejected items.
- A difference between the number of items sent and the number stored.

If you only watch status codes and the failed counters of the exporter, you do not see partial success. Compare the sent count with what arrives in the backend.

## The Collector as a receiver of partial success

A Collector OTLP receiver can also return a partial success to its callers. This happens when the receiver or a processor in the pipeline rejects some of the items and reports it. For example, some components in the pipeline return a partial-success error when part of the batch is invalid. The caller then gets 200 with `partial_success` set, and does not retry.

For this reason, a Collector in the middle of a chain can hide problems. The first Collector sees a success from the second Collector, while the second Collector dropped some items. Check the counters at each Collector, not only at the first.

## Observe a rejected item

In the playground, the second Collector `backend` writes every accepted span to its log with the `debug` exporter. A span that the receiver cannot decode is not logged there at all. Send one valid span through the first Collector and look for it in the log of the `backend`:

<!-- astrona:playground:renew -->

```sh
kubectl -n starfleet exec deploy/shuttle -- curl -s -o /dev/null -w '%{http_code}\n' -X POST -H 'Content-Type: application/json' -d '{"resourceSpans":[{"resource":{"attributes":[{"key":"service.name","value":{"stringValue":"scout"}}]},"scopeSpans":[{"scope":{"name":"lab"},"spans":[{"traceId":"5b8efff798038103d269b633813fc60c","spanId":"eee19b7ec3c1b174","name":"partial-demo","kind":2,"startTimeUnixNano":"1700000000000000000","endTimeUnixNano":"1700000001000000000"}]}]}]}' http://otelcol.observability:4318/v1/traces
```

```sh
kubectl -n observability logs deploy/backend --tail=100
```

The log of the `backend` contains the span name `partial-demo` when the whole chain works. If the first Collector answered 200 and the name is not in the log, the data was lost after the first Collector, and the exporter log and counters of the first Collector tell you where.

## Checkpoints

- A server answers HTTP 200 with `rejectedSpans: 3`. Should the sender retry?
- Which counters show a partial success: the failed counters of the exporter or the error message in the log?
- Why can a chain of two Collectors hide a partial success?

Answers: No. The log, because the transport status is a success. The second Collector reports a partial success as a success to the first one, which has no error to count.

You now know the answer that is a success on the wire and a loss in the data. The last part adds the wait that servers can ask for, and shows how to read the failure evidence on a real exporter.

## Common pitfalls

> [!WARNING]
> - Do not retry after a partial success. The accepted items would be stored twice.
> - Do not conclude that no data is lost because every status is 200.
> - Do not check only the first Collector in a chain.
