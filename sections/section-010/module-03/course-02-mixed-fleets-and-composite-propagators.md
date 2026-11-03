---
draft: true
exam_objectives:
  - Context Propagation
---
# Mixed Fleets And Composite Propagators

Most organisations do not move all services to a new header format on the same day. For months, some services write B3 headers and others write `traceparent`. This part explains what a service does when it is configured with several propagators, why that setting keeps a trace connected during a migration, and which mistakes break it.

## A list of propagators is a composite propagator

When `OTEL_PROPAGATORS` has more than one name, the SDK builds a composite propagator. The composite calls every propagator in the list, in the order given.

On inject, every propagator writes its own headers. A service configured with `tracecontext,baggage,b3` sends `traceparent`, `tracestate`, `baggage` and `b3` on every outgoing request. The same span context is written four times, in different layouts.

On extract, the composite passes the incoming headers through each propagator in turn. Each propagator that finds its headers reads them and adds the result to the context. A propagator that finds nothing leaves the context unchanged.

## What happens when two formats disagree

Suppose a request carries both `traceparent` and `b3`, with different trace identifiers, and the receiver reads `tracecontext,b3`. Both propagators find a valid header. The propagator that runs last writes the span context that wins, because it replaces the one the first propagator set.

For that reason, the order of the list matters. Put the format you trust most last when you must choose. In practice, the two headers should carry the same identifiers, because one service wrote both of them. A disagreement only appears when two different systems add headers to the same request.

## A migration from B3 to W3C Trace Context

A safe migration has an order. The goal is that no hop in the middle of a trace reads a format that the previous hop did not write.

1. Configure every service to read both formats: `OTEL_PROPAGATORS=tracecontext,baggage,b3`. Services still write both formats too, because the same variable controls inject.
2. Check with requests and with the trace view that traces stay connected. Services that run old code still write only `b3`, and new services read it.
3. When every service reads `tracecontext`, remove `b3` from the list: `OTEL_PROPAGATORS=tracecontext,baggage`.

If a service is moved to `tracecontext` only in step 1, the trace breaks at the first old service behind it. That service reads only `b3` and sees no header. It starts a new trace. This is the fault from the first module, caused by configuration and not by a proxy.

## The sampling state also crosses the format

The sampled decision travels in each format: in the trace-flags of `traceparent`, in the sampling state of `b3` and in the flags of `uber-trace-id`. A parent-based sampler reads the decision from the context the extract operation returned. If the header that carried the decision was lost, the sampler decides again, as the earlier modules showed.

## Services that read nothing

The value `none` turns propagation off. A service with `OTEL_PROPAGATORS=none` does not extract and does not inject. Each request it handles starts a new trace, and each request it sends carries no context. Use it only on purpose, for example for a service that must not link to its callers.

An empty value or a name that the SDK does not know is handled differently by each language. Some SDKs log a warning and fall back to the default. Others skip the unknown name. Check the log of the application at start.

## Run a hop-by-hop check

The playground has a `gateway` between the `shuttle` and the `probe`. In a real migration you do the same check with a header of each format.

<!-- astrona:playground:renew -->

Send all three formats in one request straight to the `probe`:

```sh
kubectl -n starfleet exec deploy/shuttle -- curl -s http://probe.starfleet/headers -H 'traceparent: 00-80f198ee56343ba864fe8b2a57d3eff7-e457b5a2e4d86bd1-01' -H 'b3: 80f198ee56343ba864fe8b2a57d3eff7-e457b5a2e4d86bd1-1' -H 'uber-trace-id: 80f198ee56343ba864fe8b2a57d3eff7:e457b5a2e4d86bd1:0:1'
```

The echo lists the three headers. This is the reference for a correct hop. Now send the same request to the `gateway` and compare. Each header that is in the first echo and missing in the second one names a format that the gateway removes.

```sh
kubectl -n starfleet exec deploy/shuttle -- curl -s http://gateway.starfleet/headers -H 'traceparent: 00-80f198ee56343ba864fe8b2a57d3eff7-e457b5a2e4d86bd1-01' -H 'b3: 80f198ee56343ba864fe8b2a57d3eff7-e457b5a2e4d86bd1-1' -H 'uber-trace-id: 80f198ee56343ba864fe8b2a57d3eff7:e457b5a2e4d86bd1:0:1'
```

The playground gateway removes the B3 and Jaeger headers and keeps `traceparent`. A fleet that has not finished its migration loses traces at this hop, even though the new services work.

## Checkpoints

- A service uses `OTEL_PROPAGATORS=tracecontext,b3`. Which headers does it write on an outgoing request?
- Why must a migration enable the new format for reading before it disables the old one?
- What does `OTEL_PROPAGATORS=none` do?

Answers: `traceparent`, `tracestate` and `b3`. A service that has not been changed still writes only the old format, and its callers must still read it. It turns extract and inject off, so every request starts a new trace.

You now know how a composite propagator keeps a trace connected through a migration. What remains is the part between the services: a proxy or gateway that forwards some headers and drops others.

## Common pitfalls

> [!WARNING]
> - Do not change one service to a new format alone. Callers that write the old format lose the link at that service.
> - Do not leave both formats on for ever. Extra headers cost bytes on every request.
> - Do not assume the order of the list is unimportant when two systems write conflicting headers.
