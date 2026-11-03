---
draft: true
exam_objectives:
  - Context Propagation
---
# Trace Context Across Process Boundaries

This module explains how a trace stays connected when a request crosses process boundaries. It covers the two W3C Trace Context headers, what a receiver does with them, and a method that finds the hop that removes them.

## Learning Goals

- Name the fields of the `traceparent` header and explain what `tracestate` carries.
- Explain what a sampler does when the parent context is missing.
- Recognise the data patterns of a broken chain: two traces, orphan spans and gaps.
- Find the hop that removes the headers by asking each hop what it received, and fix a proxy that hides them.

## Before You Start

You should know what a span and a trace are, and what an HTTP header is. The hands-on part uses a playground with a kind cluster and `kubectl`. Technical terms are defined where they first appear.

## Reading Order

1. The Trace Context Headers
2. Finding Where The Context Stops
3. Summary

<!-- astrona:playground -->
