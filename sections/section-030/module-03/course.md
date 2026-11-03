---
draft: true
exam_objectives:
  - Error Handling
---
# OTLP Responses And Retry Semantics

This module explains what an OTLP server answers when it receives telemetry, which answers make a sender retry and which make it drop the data, and what a partial success is. It then uses that knowledge to find a Collector exporter whose data is dropped because the destination answers with a permanent error.

## Learning Goals

- Name the OTLP transports, default ports, paths and content types.
- Say which gRPC and HTTP status codes a sender retries and which it treats as permanent.
- Explain a partial success response and why the sender must not retry it.
- Read the evidence that a permanent error leaves in the Collector log and in the exporter counters.

## Before You Start

You should know what an exporter, a retry and a queue are in the Collector. The hands-on part uses a playground with a kind cluster and `kubectl`.

## Reading Order

1. What An OTLP Server Answers
2. Retryable And Permanent Errors
3. Partial Success And Rejected Items
4. Throttling, Backoff And Failure Evidence
5. Summary

<!-- astrona:playground -->
