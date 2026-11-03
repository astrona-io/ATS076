---
draft: true
exam_objectives:
  - Schema Management
---
# The Layout Of A Schema File

Semantic conventions are the agreed names of attributes, such as `http.request.method`. These names change over time. A name that was right in one version may be replaced in the next. Telemetry that was produced under an older version still carries the older names. A schema file is the machine-readable record of those changes. This part describes what the file contains, so that you can read one and understand what a tool will do with it.

## What a schema file is

A schema file is a YAML document. It lists, version by version, the changes that were made to names. A tool that understands the file can read a span that uses names from one version and write it again with the names of another version.

OpenTelemetry publishes one schema file for each version of the semantic conventions. The file for a version is available at a URL of the form `https://opentelemetry.io/schemas/<version>`. That URL is the schema URL of that version. The examples in this module use an invented schema for a made-up product, with the URL `https://schemas.example.com/starfleet/1.2.0`, so that you can read the structure without relying on the details of a real release.

## The top-level fields

A schema file has three fields at the top.

```yaml
file_format: 1.1.0
schema_url: https://schemas.example.com/starfleet/1.2.0
versions:
  1.2.0:
    spans:
      changes:
        - rename_attributes:
            attribute_map:
              ship.name: starship.name
  1.1.0:
  1.0.0:
```

- `file_format` is the version of the schema file format itself, not the version of the conventions. The examples use `1.1.0`. A tool reads this value first, to know how to parse the rest.
- `schema_url` is the URL of this file, and it names the version that the file describes. By convention, it ends with the newest version listed in `versions`.
- `versions` is a map. Each key is a version number. Each value holds the changes that were introduced in that version. A version with no changes has an empty value, as `1.1.0` and `1.0.0` do in the example. It is still listed, because a tool needs to know that the version exists.

## Sections inside a version

The changes of one version are grouped by the kind of telemetry they apply to.

| Section | Applies to |
| --- | --- |
| `all` | Attributes of all signals, for a rename that is the same everywhere. |
| `resources` | Attributes of resources. |
| `spans` | Attributes of spans. |
| `span_events` | The names and attributes of span events. |
| `metrics` | The names of metrics and the attributes of metric data points. |

Each section has a key named `changes`. Its value is a list. Each item of the list is one transformation, and the key of the item names the kind of transformation.

## The kinds of transformation

The common transformations are:

- `rename_attributes`: renames attributes. It has a map named `attribute_map`.
- `rename_events` (in `span_events`): renames span events. It has a map named `name_map`.
- `rename_metrics` (in `metrics`): renames metrics. The value is a map of old names to new names.

In the example above, version `1.2.0` renames the span attribute `ship.name` to `starship.name`. The map is written as `old: new`. The key is the name before the change and the value is the name after the change. Reading the map the wrong way round is the most common mistake in reading a schema file.

## Where a schema file is used

A schema file is used by tools. A tool that supports schemas can translate telemetry to the version that a backend expects. The schema file by itself does nothing: it does not change telemetry in your pipeline unless a component reads it and applies it.

For that reason, the next part describes how the translation works and which properties a schema must have. The part after it shows where the schema URL travels in the data.

## Read a schema file in the playground

The playground has a ConfigMap named `schema-file` in the `starfleet` namespace with a schema file in the key `schema.yaml`. Print it:

<!-- astrona:playground:renew -->

```sh
kubectl -n starfleet get configmap schema-file -o jsonpath='{.data.schema\.yaml}'
```

Read the file from the top. Write down the value of `file_format` and `schema_url`. Then list the versions and find the one that has changes. Finally, read the `attribute_map` and write the sentence "attribute X was renamed to attribute Y in version Z". This file has mistakes. Compare your sentence with the description in the module landing page to find which part is wrong.

## Checkpoints

- What does `file_format` describe?
- In `attribute_map`, is the key the old name or the new name?
- Why is a version with no changes still listed?

Answers: the version of the schema file format. The key is the old name. A tool needs to know that the version exists, so it can walk from one version to another.

You now know the structure of a schema file and how to read a rename. The next part explains how a tool uses the file to move telemetry from one version to another.

## Common pitfalls

> [!WARNING]
> - Do not confuse `file_format` with the version of the conventions.
> - Do not read `old: new` as `new: old`.
> - Do not assume that a schema file changes your telemetry. A component must apply it.
