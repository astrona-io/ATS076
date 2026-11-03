---
draft: true
exam_objectives:
  - Debugging Pipelines
---
# Locating Data Loss Between Stages

Data that enters a Collector and never reaches the backend was removed by one stage. This module shows how to find that stage with the Collector's own counters and how to correct the processor rule that removes too much.

## Learning Goals

- Compare receiver, processor and exporter counters to find the stage that loses items.
- Explain how the filter processor decides which spans to drop.
- Correct an inverted drop condition and prove the result with a kept and a dropped span.

## Before You Start

You should have completed the previous module and know how to read the internal metrics on port 8888.

## Reading Order

1. Counting Items Between Stages
2. Processors That Drop Data
3. Summary

<!-- astrona:playground -->
