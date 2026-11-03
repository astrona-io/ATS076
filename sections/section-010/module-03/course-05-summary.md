---
draft: true
exam_objectives:
  - Context Propagation
---
# Summary

A propagator knows one header format. The `tracecontext` propagator uses `traceparent` and `tracestate`. The `b3` propagator uses one header named `b3`, and `b3multi` uses several headers that start with `X-B3-`. The `jaeger` propagator uses `uber-trace-id`. The environment variable `OTEL_PROPAGATORS` lists the formats that a service reads and writes, and its default is `tracecontext,baggage`.

A list with several names builds a composite propagator. It writes every format on inject and reads every format on extract. A migration between formats first makes every service read both formats and only then removes the old one. A service that reads only a new format cuts the trace at the first caller that still writes the old one.

A proxy or gateway can break a format that the services support. A proxy that forwards all headers by default breaks propagation only when a rule removes a header. An allow-list breaks it whenever a format is not on the list. The allow-list must contain every header name of every format in use, and a browser that calls another origin needs the trace headers in `Access-Control-Allow-Headers`.

The test is a request that carries a header of every format and a marker header that must stay hidden. Comparing the echo of each hop with the echo of the next hop names the header that is removed. A correct repair removes only the rule that hides the trace headers, restarts the proxy and checks both sides.

Key facts:

- B3 may carry a 64-bit trace identifier, which OpenTelemetry pads to 128 bits.
- `OTEL_PROPAGATORS=none` turns propagation off.
- A receiver ignores an incomplete set of `X-B3-` headers.
- Security rules on a proxy must survive a propagation repair.

<!-- astrona:playground:destroy -->
