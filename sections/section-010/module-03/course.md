---
draft: true
exam_objectives:
  - Context Propagation
---
# Propagator Formats And Header Allow-lists

This module explains that the W3C Trace Context headers are not the only way to carry a span context. It covers the B3 and Jaeger formats, how a service chooses the formats it reads and writes, and how a proxy that filters headers can break a format that it does not know.

## Learning Goals

- Name the headers of the `tracecontext`, `b3`, `b3multi` and `jaeger` propagators.
- Explain what a service does when it receives more than one format, and why a mixed fleet needs a composite propagator.
- List the headers an allow-list proxy must forward for each format, and the browser rule for cross-origin requests.
- Prove with requests which header names reach a backend through a proxy.

## Before You Start

You should know the `traceparent` header and what a reverse proxy does. The hands-on part uses a playground with a kind cluster and `kubectl`.

## Reading Order

1. One Span Context, Several Header Formats
2. Mixed Fleets And Composite Propagators
3. Proxies, Allow-lists And Browsers
4. Proving Header Formats With Requests
5. Summary

<!-- astrona:playground -->
