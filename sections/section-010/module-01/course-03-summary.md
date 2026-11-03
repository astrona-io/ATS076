---
draft: true
exam_objectives:
  - Context Propagation
---
# Summary

A span context is the set of values that must travel from one process to the next: the trace identifier, the parent span identifier and the flags. An injector at the sender writes it into the carrier, which for HTTP is the request headers. An extractor at the receiver reads it and makes it the parent of the next span. The `traceparent` header holds the version, the trace-id, the parent-id and the trace-flags, and `tracestate` holds vendor data.

When the header is missing or invalid, the receiver starts a new trace and its sampler decides alone. That produces two traces instead of one, with different sampling rates on each side. A correct trace-id with a missing parent is a different fault: the data was lost after it was recorded.

The way to find a propagation fault is to ask each hop what it received, starting at the last hop and moving towards the entry point. The first hop that does not see the header is the one that removes it. A reverse proxy such as nginx removes a header when a rule sets it to an empty value, and it reads its rules only at start, so it must restart after a change.

Key facts:

- Only `traceparent` decides trace identity. `tracestate` carries vendor data and may be lost without cutting the trace.
- An invalid `traceparent` makes the receiver ignore it and start a new trace.
- A parent-based sampler follows the sampled flag of the parent only when a parent exists.
- A configuration change to a proxy takes effect after the proxy restarts.

<!-- astrona:playground:destroy -->
