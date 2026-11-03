---
draft: true
exam_objectives:
  - Context Propagation
---
# Baggage And Trust Boundaries

This module explains baggage, the key-value data that travels with a request, and why a public edge must not forward it from unknown callers. It ends with a proxy configuration that applies different header rules to a public and an internal listener.

## Learning Goals

- Explain how baggage is written, forwarded and read, and why it does not appear on spans.
- List the limits and the risks of putting data in baggage.
- Explain what a caller can do with `baggage`, `traceparent` and `tracestate` at a trust boundary.
- Apply a header rule to one nginx listener only and prove the result with requests.

## Before You Start

You should know the `traceparent` header and what a reverse proxy does. The hands-on part uses a playground with a kind cluster and `kubectl`.

## Reading Order

1. Baggage And How It Travels
2. Untrusted Context At The Edge
3. Summary

<!-- astrona:playground -->
