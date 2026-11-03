---
draft: true
exam_objectives:
  - Context Propagation
---
# Summary

Baggage is a set of key-value pairs that travels in the `baggage` header next to the trace context. It lives in the context and is separate from span attributes, so it does not appear in a trace unless code copies a member to a span. An injector writes it to outgoing requests and an extractor reads it from incoming requests, when the baggage propagator is enabled.

Baggage has no owner and no signature. Any service on the path can read, add, change or remove a member, and every service receives it in clear text. It suits small, stable values and does not suit secrets, large data or authorization decisions.

At a trust boundary the edge decides per header what to forward. A public caller can write any baggage and can set the sampled flag in `traceparent`. A rule that sets `baggage` to an empty value removes the header in nginx, and a rule in one `server` block applies only to that listener. A policy is proven by tests that confirm each forward and each removal.

Key facts:

- The default propagators are `tracecontext` and `baggage`.
- A platform must support at least 64 members and 8192 bytes of baggage.
- An empty header value is not passed on by nginx.
- A check for a removed header must be paired with a check that the other headers still arrive.

<!-- astrona:playground:destroy -->
