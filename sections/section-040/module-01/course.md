---
draft: true
exam_objectives:
  - Debugging Pipelines
---
# Semantic Conventions And Renaming

Spans that arrive complete can still be unusable when consumers query names that the data does not carry. This module explains semantic conventions, why attribute names change between versions, and how the transform processor makes names uniform.

## Learning Goals

- Explain what the OpenTelemetry semantic conventions define.
- Name common legacy and stable HTTP attribute names and where to verify them.
- Write a transform processor rule that renames an attribute safely.
- Prove a rename with a legacy span and a stable span.

## Before You Start

You should know how a pipeline is built and how to read the debug exporter output.

## Reading Order

1. Semantic Conventions And Attribute Names
2. Renaming Attributes With OTTL
3. Summary

<!-- astrona:playground -->
