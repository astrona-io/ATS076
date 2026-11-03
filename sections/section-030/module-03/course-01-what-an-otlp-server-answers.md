---
draft: true
exam_objectives:
  - Error Handling
---
# What An OTLP Server Answers

Every SDK exporter and every Collector exporter that uses the OpenTelemetry protocol sends a request and waits for an answer. The answer decides what the sender does next: it forgets the data, sends it again or drops it. To handle errors, you first need to know what a normal answer looks like. This part describes the transports of the OpenTelemetry Protocol (OTLP), their defaults and the shape of a successful answer.

## One protocol, two transports

OTLP defines how telemetry is encoded and sent. It has two transports that carry the same data.

- **OTLP/gRPC** uses a gRPC call. The default port is 4317. The services are `TraceService`, `MetricsService` and `LogsService`, each with one method named `Export`.
- **OTLP/HTTP** uses HTTP POST requests. The default port is 4318. Each signal has its own path: `/v1/traces`, `/v1/metrics` and `/v1/logs`.

For OTLP/HTTP, the request body is a Protocol Buffers message or its JSON form. The header `Content-Type` tells the server which one: `application/x-protobuf` or `application/json`. The sender may compress the body and say so with `Content-Encoding: gzip`.

The path is part of the contract. A request to `/v1/trace` or to `/v1/traces/v1/traces` is not an OTLP request. A Collector receiver answers it with status 404, because it serves only the three paths.

## The Collector exporter adds the path

A common source of errors is the endpoint setting of the OTLP/HTTP exporter. In the Collector, the exporter takes a base URL in `endpoint` and adds the signal path itself:

```yaml
exporters:
  otlp_http/backend:
    endpoint: http://backend.observability:4318
```

For traces, this exporter sends to `http://backend.observability:4318/v1/traces`. If you write the full path in `endpoint`, the exporter adds the path a second time. The request goes to `/v1/traces/v1/traces`, and the destination answers 404. When you need a full URL for one signal, use the signal-specific settings such as `traces_endpoint`, which are used as written.

The gRPC exporter is different. It takes `host:port` and no path, because the method name is part of the gRPC call.

## A successful answer

A successful OTLP/HTTP export answers with status 200 and a response body. The body is an `ExportTraceServiceResponse` for traces, with matching messages for metrics and logs. When everything was accepted, the body has no fields set, so it is empty or nearly empty.

A gRPC export answers with the gRPC status `OK` and the same response message.

The sender treats a success as final. It removes the data from its queue, and it does not send it again.

## What an answer can contain besides success

The response message has one optional field, `partial_success`. The server uses it to say that it accepted the request but could not keep some of the items. The next parts describe it in detail. All error answers are either an HTTP status code of 4xx or 5xx, or a gRPC status other than `OK`. For an error, the body is a `google.rpc.Status` message with a code, a message and optional details.

## Observe the answers in the playground

The playground has a Collector `otelcol`, which receives spans over OTLP/HTTP and exports them to a second Collector named `backend`. Send one valid span to the first Collector and print the status code:

<!-- astrona:playground:renew -->

```sh
kubectl -n starfleet exec deploy/shuttle -- curl -s -o /dev/null -w '%{http_code}\n' -X POST -H 'Content-Type: application/json' -d '{"resourceSpans":[]}' http://otelcol.observability:4318/v1/traces
```

The status is 200, because an empty list of spans is a valid request. Now send the same body to a path that the receiver does not serve:

```sh
kubectl -n starfleet exec deploy/shuttle -- curl -s -o /dev/null -w '%{http_code}\n' -X POST -H 'Content-Type: application/json' -d '{"resourceSpans":[]}' http://otelcol.observability:4318/v1/traces/v1/traces
```

The status is 404. Finally, send a body that is not valid JSON:

```sh
kubectl -n starfleet exec deploy/shuttle -- curl -s -o /dev/null -w '%{http_code}\n' -X POST -H 'Content-Type: application/json' -d '{not json' http://otelcol.observability:4318/v1/traces
```

The status is 400, because the server cannot decode the request. In the next part you will see how a sender treats each of these three answers.

## Checkpoints

- Which default ports do OTLP/gRPC and OTLP/HTTP use?
- You set `endpoint: http://backend:4318/v1/traces` on the OTLP/HTTP exporter. Which path does the request use?
- Which header tells the server whether the body is protobuf or JSON?

Answers: 4317 and 4318. `/v1/traces/v1/traces`, because the exporter adds the path. `Content-Type`.

You now know the shape of a normal answer and one common way to turn it into an error. The next part sorts the error answers into the ones a sender should retry and the ones it must not.

## Common pitfalls

> [!WARNING]
> - Do not put a signal path in the `endpoint` of the Collector OTLP/HTTP exporter.
> - Do not send OTLP/HTTP to port 4317 or OTLP/gRPC to port 4318. The protocol does not match the listener.
> - Do not treat a 200 as proof that every item was stored. A partial success also answers 200.
