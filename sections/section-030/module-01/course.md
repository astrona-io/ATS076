---
draft: true
exam_objectives:
  - Debugging Pipelines
---
# Exporter Retry And Queues

When a backend is unreachable, an exporter either holds the data or drops it. This module explains the retry and queue settings that decide which, how to size a queue, and how to keep it across a restart.

## Learning Goals

- Follow a batch through the exporter and say where it waits or is dropped.
- Configure retry_on_failure and sending_queue for an exporter.
- Estimate a queue size from a rate and an outage length.
- Keep a queue across restarts with the file_storage extension.

## Before You Start

You should know how a pipeline is built and how to read the internal metrics on port 8888.

## Reading Order

1. What Happens When An Export Fails
2. Sizing Queues And Persistent Storage
3. Summary

<!-- astrona:playground -->
