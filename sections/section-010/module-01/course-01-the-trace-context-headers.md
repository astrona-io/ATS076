---
draft: true
exam_objectives:
  - Context Propagation
---
# The Trace Context Headers

A checkout request enters a gateway, the gateway calls an order service, and the order service calls a payment service. Each service records spans. For the trace view to show one tree, every span must carry the same trace identifier, and every span except the first must name its parent. The services do not share memory, so the only way to pass those two facts is inside the request itself. This part explains the two HTTP headers that carry them and what each field means.

## What context propagation is

A span is a record of one operation. It has a trace identifier, a span identifier, an optional parent span identifier and a set of flags. The set of values that must travel from one process to the next is called the span context. Propagation is the act of writing the span context into a carrier at the sender and reading it back at the receiver. For HTTP, the carrier is the set of request headers.

Two pieces of code do the work:

- An **injector** at the sender copies the current span context into the headers of an outgoing request.
- An **extractor** at the receiver reads the headers of an incoming request and makes the result the parent of the next span that the receiver starts.

Both pieces belong to a **propagator**. A propagator is a small component that knows one header format. The instrumentation library or the application calls it; the Collector is not involved in this step. The Collector only receives the spans after the fact and cannot repair a link that was never written.

## The traceparent header

The W3C Trace Context standard defines the header `traceparent`. It has four fields separated by a dash:

```
traceparent: 00-0af7651916cd43dd8448eb211c80319c-b7ad6b7169203331-01
```

| Field | Example | Length | Meaning |
| --- | --- | --- | --- |
| version | `00` | 2 hex characters | Format version. `00` is the version in use. `ff` is not allowed. |
| trace-id | `0af7651916cd43dd8448eb211c80319c` | 32 hex characters | The identifier shared by every span of the trace. |
| parent-id | `b7ad6b7169203331` | 16 hex characters | The identifier of the span that made this request. The receiver's new span uses it as its parent. |
| trace-flags | `01` | 2 hex characters | Eight flag bits. Bit 0 is the sampled flag. |

Rules a receiver applies:

- The characters must be lowercase hexadecimal. A header with uppercase letters is invalid.
- A trace-id made of only zeros is invalid. A parent-id made of only zeros is invalid.
- If the header is invalid, the receiver ignores it and starts a new trace. The request is still served.
- The sampled flag `01` means the caller recorded this trace and asks others to record it too. The value `00` means the caller did not record it.

The parent-id changes at every hop. The service that sends a request writes the identifier of its own client span there. The trace-id never changes.

## The tracestate header

The `tracestate` header carries vendor-specific data next to `traceparent`:

```
tracestate: vendor=starfleet,other=value
```

It is a comma-separated list of `key=value` members. The standard limits the list to 32 members. A vendor that changes its own member moves it to the front of the list. The header is never the source of the trace identity: only `traceparent` is. If a receiver finds `traceparent` invalid, it must also discard `tracestate`.

A proxy that forwards `traceparent` but removes `tracestate` still keeps the trace connected. The trace tree stays intact and only the vendor data is lost. That makes a missing `tracestate` a quiet fault that no trace view shows.

## The sampled flag and the sampler

Whether a span is recorded is decided by a sampler. The sampler `parentbased_traceidratio` first looks at the parent. If a remote parent exists, it follows the parent's sampled flag. Only when there is no parent does it apply the ratio to the trace-id.

Consider what happens when a hop loses the header:

1. The caller recorded the trace with the flag `01`.
2. The proxy removes `traceparent`.
3. The next service finds no parent. It is now a root and applies the ratio on its own.
4. With a ratio of `0.1` it records one trace in ten.

So losing the context has two visible effects. The trace is cut in two, and the downstream half is recorded at a different rate than the upstream half. Counting spans on both sides shows a mismatch that looks like random data loss but is a propagation fault.

## Default propagators in OpenTelemetry

The environment variable `OTEL_PROPAGATORS` sets the formats an SDK uses. Its default is:

```
OTEL_PROPAGATORS=tracecontext,baggage
```

`tracecontext` is `traceparent` and `tracestate`. `baggage` is the header covered in another module. Other values exist for older systems, for example `b3`, `b3multi` and `jaeger`. A service configured with `jaeger` writes a header named `uber-trace-id`. A service configured with `tracecontext` does not read that header. When two services use different formats, the trace breaks even though no proxy removed anything.

You can send both formats from one service by listing both: `OTEL_PROPAGATORS=tracecontext,baggage,b3`. The receiver extracts with the formats it knows, in the order listed.

## What a broken chain looks like

A broken chain shows in the data as one of these patterns:

- **Two traces instead of one.** The upstream trace ends at the caller's client span. The downstream spans have a different trace-id and a root span with no parent.
- **Orphan spans.** The downstream spans keep the trace-id but name a parent-id that does not exist in the store, for example because the parent span was not sampled or was dropped.
- **Gaps in a tree.** A hop that is not instrumented receives and forwards the headers, but records no span. The tree skips a level but stays connected.

These patterns differ in where the fault is. A new trace-id means the extraction did not happen or the header was missing. A correct trace-id with a missing parent means the data was lost later, in the pipeline or in the sampler. The first is a propagation fault and the second is a delivery fault.

## Headers are case-insensitive, values are not

HTTP header names are case-insensitive. `Traceparent`, `traceparent` and `TRACEPARENT` name the same header, and HTTP/2 sends them in lowercase. Values are case-sensitive for `traceparent`: it must be lowercase hex. A proxy that rewrites header values to upper case makes every trace header invalid.

## Checkpoints

- Name the four fields of `traceparent` and say which of them changes at every hop.
- A service sends `traceparent` with the flag `00`. A downstream service uses `parentbased_traceidratio`. Does it record the trace?
- A proxy removes `tracestate` and keeps `traceparent`. Is the trace still connected?
- Two services use `OTEL_PROPAGATORS=jaeger` and `OTEL_PROPAGATORS=tracecontext`. What does the trace view show?

Answers: the version, trace-id, parent-id and trace-flags, and the parent-id changes. A parent-based sampler follows the parent's flag, so it does not record. Yes, the trace stays connected and only vendor data is lost. Two separate traces, because neither service reads the other's header.

You now know which fields travel in the two headers, what each receiver does with them and which data patterns a broken chain produces. The open question is where in a real request path the headers are lost, and how to prove it with a request instead of a guess.

## Common pitfalls

> [!WARNING]
> - Do not treat a missing `tracestate` as a broken trace. The tree stays connected without it.
> - Do not read two separate traces as a Collector fault. A new trace-id means the header never arrived at the receiver.
> - Do not mix propagator formats between services without listing both formats on the services that must read both.
> - Do not assume a downstream service records a trace because the upstream service did. A sampler without a parent decides on its own.
