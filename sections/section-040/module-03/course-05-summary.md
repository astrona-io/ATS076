---
draft: true
exam_objectives:
  - Schema Management
---
# Summary

A schema file is a YAML document that records, version by version, which names changed in the semantic conventions. It has three top-level fields. The field `file_format` names the version of the file format, `schema_url` names the version that the file describes, and `versions` maps each version to its changes. Changes are grouped in sections for all signals, resources, spans, span events and metrics, and each section has a list named `changes`.

The common transformations are `rename_attributes` with an `attribute_map`, `rename_events` with a `name_map` and `rename_metrics`. In every map, the key is the old name and the value is the new name. A tool that translates telemetry walks the versions in order and applies the changes as written when it moves up. When it moves down, it applies them in reverse, so each rename must be one to one.

OTLP data carries a schema URL on the resource and on the instrumentation scope, and the two can name different versions. An empty URL means the version is unknown. The URL is a claim by the producer, and nothing in the Collector checks that the names match it. A schema file by itself changes no telemetry, because a component must apply it. Without such a component, the same rename is written as OTTL statements in the `transform` processor.

A schema file can be wrong without an error message. A review checks the format line, the URL, the list of versions, the spelling of the keys and the direction of every map. A file that passes is then tested with a real span and compared with the consumers that use the names.

Key facts:

- In `old: new`, the key is the name before the change.
- A released version section must not change.
- A misspelled transformation key may be skipped without an error.

<!-- astrona:playground:destroy -->
