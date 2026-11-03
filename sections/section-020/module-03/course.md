---
draft: true
exam_objectives:
  - Debugging Pipelines
---
# Collector Diagnostic Extensions

This module explains the extensions that let you look inside a running OpenTelemetry Collector: the `zpages` extension, the `pprof` extension and the `health_check` extension. It also explains why an extension that you configured may not be reachable, and which tool answers which question.

## Learning Goals

- Explain what an extension is and why it must be listed in `service.extensions` to start.
- Use the `zpages` pages to see the pipelines and the components of a running Collector.
- Explain what the `pprof` extension offers and why its port must not be public.
- Explain why an endpoint that is bound to `localhost` cannot be reached from another pod, and how to reach it anyway.
- Choose between the health check, internal metrics, logs, the debug exporter and zPages for a given question.

## Before You Start

You should know the sections of a Collector configuration and why a component that is defined but not listed does nothing. The hands-on part uses a playground with a kind cluster and `kubectl`.

## Reading Order

1. What An Extension Is And How It Starts
2. The zPages Extension
3. The pprof Extension And The Health Check
4. Choosing The Right Diagnostic Tool
5. Summary

<!-- astrona:playground -->
