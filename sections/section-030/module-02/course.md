---
draft: true
exam_objectives:
  - Debugging Pipelines
---
# Protecting The Collector Memory

A Collector that runs out of memory is killed and loses everything it holds. This module explains the memory_limiter processor, how to choose its limits, why its position matters, and what a refusal does to the senders.

## Learning Goals

- Explain the soft and hard limits of the memory_limiter processor.
- Choose limit_mib and spike_limit_mib for a container memory limit.
- Place the processor first and say why.
- Describe what happens to senders when data is refused.

## Before You Start

You should know how a pipeline is built and how exporters queue data.

## Reading Order

1. The Memory Limiter
2. Refusing Data And Its Effect On Senders
3. Summary

<!-- astrona:playground -->
