---
draft: true
exam_objectives:
  - Schema Management
---
# Transformations And Their Direction

A schema file lists changes, but a change is only useful when something applies it. Telemetry can be moved to a newer version, or back to an older one. This part explains how a tool walks the versions in a schema file, why the direction matters and which properties a rename must have so that it can be applied both ways.

## Moving between two versions

Suppose a span carries the schema URL of version 1.0.0, and a backend expects version 1.2.0. A tool that reads the schema file builds the list of versions between the two, in order: 1.1.0 and 1.2.0. It applies the changes of each version in that order to the span.

Changes are applied in the order of the versions, and within a version in the order of the list `changes`. The result is a span that uses the names of version 1.2.0. The tool then sets the schema URL of the span to the URL of version 1.2.0.

This is the upward direction. The changes are applied as written, so `ship.name: starship.name` renames `ship.name` to `starship.name`.

## The downward direction

A tool can also move telemetry to an older version. A backend that is still built on version 1.0.0 may need that. The tool then walks the versions from the newer one to the older one, and applies each change in reverse. The map `ship.name: starship.name` is read as `starship.name: ship.name`.

The reverse of a rename is possible only if the rename is one to one. A rename is one to one when each old name maps to exactly one new name and no two old names map to the same new name. If two attributes were merged into one in a later version, there is no way to know which of the two the new attribute came from. The schema format limits its transformations to a small set, mostly renames, so that translation stays well-defined in both directions.

## Rules for a safe rename

To keep a schema usable in both directions, a rename should follow these rules.

- Each old name appears once as a key in one `attribute_map`.
- No new name is the target of two keys.
- A new name is not also an old name in the same version. A rename of `a` to `b` and of `b` to `c` in the same version has an unclear order.
- A change that is not a rename, such as a change of the value type or of the meaning, is not described by the schema file. Such a change needs a note in the convention documentation and usually a manual step.

## Order of versions

Version keys are compared as version numbers, not as text. A tool sorts `1.10.0` after `1.9.0`. When you write a schema file by hand, do not rely on the order of the keys in the YAML. Keep them in descending order, newest first, so that a person can find the latest changes at the top of the file.

## Apply a rename without a schema component

Not every pipeline has a component that reads schema files. The Collector can still apply the same rename with the OpenTelemetry Transformation Language (OTTL), in the `transform` processor. A rename from a schema entry becomes two statements, one that copies the value and one that removes the old name:

```yaml
processors:
  transform/rename:
    trace_statements:
      - set(span.attributes["starship.name"], span.attributes["ship.name"]) where span.attributes["ship.name"] != nil
      - delete_key(span.attributes, "ship.name") where span.attributes["starship.name"] != nil
```

The first statement copies the value only when the old attribute exists. The second one removes the old attribute only when the new one exists. This way a span that has only the new name stays unchanged. The statements follow the direction of the schema entry: they perform the upward change. A downward change needs the statements with the names swapped.

## Observe the direction in the playground

In the playground, the schema file contains one rename. Print the file as in the previous part and write the two sentences that a tool would apply.

<!-- astrona:playground:renew -->

```sh
kubectl -n starfleet get configmap schema-file -o jsonpath='{.data.schema\.yaml}'
```

The first sentence is the upward change: "rename X to Y". The second one is the downward change: "rename Y to X". If the file lists the map the wrong way round, the upward sentence says the reverse of what the product team did, and every translation produces names that no consumer queries. A quick test is to check one real attribute: the old name must be the one that existing dashboards already use.

## Checkpoints

- A tool moves a span from 1.0.0 to 1.2.0. In which order does it apply the changes?
- Why must a rename be one to one?
- Which OTTL function copies a value into the new attribute?

Answers: the changes of 1.1.0, then those of 1.2.0, each in list order. Without it, a downward translation cannot decide which old name to restore. `set`.

You now know how a tool walks the versions and why direction matters. The next part follows the schema URL through the data, where a tool finds the starting version.

## Common pitfalls

> [!WARNING]
> - Do not map two old names to one new name. The downward direction becomes ambiguous.
> - Do not chain renames in one version. Split them into two versions.
> - Do not copy the OTTL statements for the upward change and use them for the downward change.
