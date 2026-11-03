---
draft: true
exam_objectives:
  - Debugging Pipelines
---
# Components And Pipelines

This module explains how the OpenTelemetry Collector turns a configuration into running pipelines, and how to collect evidence about what it accepts. It ends with the most common fault in a new configuration: a component that is defined but not used.

## Learning Goals

- Name the sections of a Collector configuration and say which of them start components.
- Explain why a defined but unlisted receiver, processor or extension does nothing.
- Use the debug exporter, the health check and the internal metrics as evidence.
- Send a test span over OTLP/HTTP and trace it through the Collector.

## Before You Start

You should know what a span is and how to read a YAML file. The hands-on part uses a playground with a kind cluster and `kubectl`.

## Reading Order

1. How A Collector Builds Pipelines
2. Checking Intake With Debug, Health And Metrics
3. Summary

<!-- astrona:playground -->
