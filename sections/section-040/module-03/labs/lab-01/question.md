# Question

Solve this question on: `terminal`

The ConfigMap `schema-file` in the `starfleet` namespace holds a schema file in the key `schema.yaml`. It describes two renames for an invented product: the span attribute `ship.name` becomes `starship.name` in version 1.2.0, and the resource attribute `crew.id` becomes `member.id` in version 1.1.0. The file has mistakes.

1. Print the file and review it with the checklist from the module: format line, schema URL, versions, key spelling and the shape of every map.
2. Edit the ConfigMap so that the file is correct. The schema URL of the file is `https://schemas.example.com/starfleet/1.2.0`.
3. Keep all three versions, 1.2.0, 1.1.0 and 1.0.0, and keep the direction of both renames.

`kubectl` already points at the cluster. The Collector in `observability` is not part of the task.
