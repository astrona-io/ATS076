---
draft: true
exam_objectives:
  - Debugging Pipelines
---
# Migration Windows

A rename in the Collector can break dashboards and alerts that still query the old names. This module explains schema versions, who is affected by a rename, and how a dual emission window keeps both names until every consumer has moved.

## Learning Goals

- Explain what a schema URL tells you and what it does not.
- List the groups of consumers that depend on attribute names.
- Compare big bang, consumers first and dual emission rollouts.
- Build and prove a transform rule that emits both names.

## Before You Start

You should have completed the previous module and know how a transform processor renames attributes.

## Reading Order

1. Schema Versions And Compatibility For Consumers
2. Dual Emission During A Migration
3. Summary

<!-- astrona:playground -->
