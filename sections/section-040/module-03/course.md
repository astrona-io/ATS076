---
draft: true
exam_objectives:
  - Schema Management
---
# Schema Files And Transformations

This module explains the OpenTelemetry schema file: the document that records which attribute, event and metric names changed between versions of the semantic conventions. It covers the layout of the file, how a tool reads it to translate names up or down, where the schema URL appears in OTLP data and how to check a schema file by hand.

## Learning Goals

- Name the top-level fields of a schema file and the sections inside a version.
- Read a `rename_attributes` entry and say which name is the old one and which is the new one.
- Explain how a tool translates telemetry from one schema version to another, and why a rename must be one to one.
- Say where the schema URL appears in OTLP data and what it does and does not guarantee.
- Check a schema file for the common mistakes with simple text tools.

## Before You Start

You should know what a semantic convention is and why an attribute rename can break a dashboard. The hands-on part uses a playground with a kind cluster and `kubectl`.

## Reading Order

1. The Layout Of A Schema File
2. Transformations And Their Direction
3. Schema URLs In OTLP Data
4. Checking A Schema File By Hand
5. Summary

<!-- astrona:playground -->
