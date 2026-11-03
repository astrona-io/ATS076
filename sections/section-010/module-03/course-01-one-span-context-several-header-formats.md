---
draft: true
exam_objectives:
  - Context Propagation
---
# One Span Context, Several Header Formats

A span context holds a trace identifier, a span identifier and a sampling decision. The W3C Trace Context standard is one way to write those values into HTTP headers. Older tracing systems defined their own ways before the standard existed, and many services still use them. This part lists the formats that OpenTelemetry can read and write, and shows the header names of each one.

## What a propagator is

A propagator is a component of the OpenTelemetry API that knows one header format. It has two jobs. The inject operation writes the current span context into the headers of an outgoing request. The extract operation reads the headers of an incoming request and returns a context that the next span can use as its parent.

The span context is the same data in every format. Only the header names and the text layout differ. Because the layout differs, a service that reads one format cannot understand a header written in another format.

## The names you set in OTEL_PROPAGATORS

The environment variable `OTEL_PROPAGATORS` holds a comma-separated list of propagator names. The values defined by the OpenTelemetry specification are:

- `tracecontext`: the W3C `traceparent` and `tracestate` headers.
- `baggage`: the W3C `baggage` header.
- `b3`: one header named `b3`.
- `b3multi`: several headers whose names start with `X-B3-`.
- `jaeger`: one header named `uber-trace-id`.
- `xray`, `ottrace` and `none`: the AWS X-Ray format, the legacy OpenTracing format and no propagation at all.

The default value is `tracecontext,baggage`. The names `b3`, `b3multi`, `jaeger`, `xray` and `ottrace` are not part of every SDK by default. In many languages they live in a separate package that the application must install and enable.

## The B3 format

B3 comes from the Zipkin project. It has a single-header form and a multi-header form.

The single-header form is one header named `b3`:

```
b3: 80f198ee56343ba864fe8b2a57d3eff7-e457b5a2e4d86bd1-1-05e3ac9a4f6e3b90
```

The fields are separated by a dash: the trace identifier, the span identifier, the sampling state and, optionally, the parent span identifier. The sampling state is `1` for sampled, `0` for not sampled and `d` for debug.

The multi-header form splits the same values over separate headers:

```
X-B3-TraceId: 80f198ee56343ba864fe8b2a57d3eff7
X-B3-SpanId: e457b5a2e4d86bd1
X-B3-Sampled: 1
X-B3-ParentSpanId: 05e3ac9a4f6e3b90
```

B3 allows a trace identifier of 16 hexadecimal characters (64 bits) as well as 32 characters (128 bits). A 64-bit identifier is padded with zeros on the left when OpenTelemetry reads it, because an OpenTelemetry trace identifier always has 128 bits.

## The Jaeger format

The Jaeger propagator uses one header named `uber-trace-id`. It has four fields separated by a colon:

```
uber-trace-id: 80f198ee56343ba864fe8b2a57d3eff7:e457b5a2e4d86bd1:0:1
```

The fields are the trace identifier, the span identifier, the parent span identifier (which is deprecated and usually written as `0`) and the flags. The lowest bit of the flags is the sampled decision.

## Comparing the formats

| Format | Header names | Layout |
| --- | --- | --- |
| `tracecontext` | `traceparent`, `tracestate` | `version-trace_id-parent_id-flags` |
| `b3` | `b3` | `trace_id-span_id-sampling[-parent_id]` |
| `b3multi` | `X-B3-TraceId`, `X-B3-SpanId`, `X-B3-Sampled`, `X-B3-ParentSpanId` | one value per header |
| `jaeger` | `uber-trace-id` | `trace_id:span_id:parent_id:flags` |

HTTP header names are not case sensitive, so `X-B3-TraceId` and `x-b3-traceid` are the same header. HTTP/2 sends all names in lower case.

## Run the formats in the playground

The playground has a `shuttle` pod with `curl`, a `probe` that echoes the request headers and a `gateway` proxy. First send a B3 single header straight to the `probe`:

<!-- astrona:playground:renew -->

```sh
kubectl -n starfleet exec deploy/shuttle -- curl -s http://probe.starfleet/headers -H 'b3: 80f198ee56343ba864fe8b2a57d3eff7-e457b5a2e4d86bd1-1'
```

The answer lists a `B3` entry with the same value. The `probe` does not read it as a span context. It only shows that the header arrived. Now send the Jaeger header:

```sh
kubectl -n starfleet exec deploy/shuttle -- curl -s http://probe.starfleet/headers -H 'uber-trace-id: 80f198ee56343ba864fe8b2a57d3eff7:e457b5a2e4d86bd1:0:1'
```

The echo lists `Uber-Trace-Id`. The probe capitalises the first letter of each part of a header name. That change is made by the `probe`, not by your request.

## Checkpoints

- Which header names does the `b3multi` propagator write?
- What is the default value of `OTEL_PROPAGATORS`?
- A service sends a 64-bit B3 trace identifier. What does an OpenTelemetry receiver do with it?

Answers: `X-B3-TraceId`, `X-B3-SpanId`, `X-B3-Sampled` and `X-B3-ParentSpanId`. The default is `tracecontext,baggage`. It pads the identifier with zeros on the left to 128 bits.

You now know the header names and layouts of the common formats. The open question is what happens when one request carries more than one format, or when two services in the same trace read different formats.

## Common pitfalls

> [!WARNING]
> - Do not assume that `b3` and `b3multi` are the same setting. A service that reads only `b3` ignores the `X-B3-` headers.
> - Do not expect `OTEL_PROPAGATORS=jaeger` to work without the Jaeger propagator package installed in the application.
> - Do not read the capital letters in an echo as a change made by the sender. Header names are case insensitive.
