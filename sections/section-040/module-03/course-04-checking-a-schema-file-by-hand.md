---
draft: true
exam_objectives:
  - Schema Management
---
# Checking A Schema File By Hand

A schema file that is wrong does harm without an error message. A reversed rename produces wrong names, a misspelled key is ignored by a tolerant parser, and a wrong URL points tools at the wrong version. This part gives a short checklist that finds the common mistakes with plain text tools, so that you can review a schema file before it reaches a pipeline.

## The checklist

Check these five things, in this order.

1. **The format line.** The file starts with `file_format` and a version that the tools in your pipeline support. The examples use `1.1.0`.
2. **The schema URL.** The field `schema_url` is present, and its last path segment is the newest version in `versions`.
3. **The versions.** Every version that ever existed is listed, including those with no changes. Removing an old version breaks translation for data that still uses it.
4. **The keys.** The names of the transformations are spelled exactly as the format defines them. The key is `rename_attributes`, with a final `s`. A misspelled key such as `rename_attribute` is not a transformation, and a tolerant reader may skip it without an error.
5. **The direction.** In every map, the key is the old name and the value is the new name. Check one pair against a real, current dashboard: the name the dashboards use today must be the key of the oldest change.

## Find mistakes with grep

A few `grep` commands find most problems. Print the file once into a shell variable, so that each check reads the same text:

<!-- astrona:playground:renew -->

```sh
kubectl -n starfleet get configmap schema-file -o jsonpath='{.data.schema\.yaml}' > schema.yaml
```

Check the format line and the URL:

```sh
grep -n '^file_format:' schema.yaml
grep -n '^schema_url:' schema.yaml
```

Each command prints one line with its line number. If one prints nothing, the field is missing. Compare the last segment of the URL with the newest version in the list of versions:

```sh
grep -n '^  [0-9][0-9.]*:' schema.yaml
```

This prints each version key. Then check the transformation keys, which must end in `s`:

```sh
grep -n 'rename_' schema.yaml
```

A line that reads `rename_attribute:` without the final `s` is a mistake. Finally, print the map and apply the direction rule:

```sh
grep -n -A3 'attribute_map' schema.yaml
```

Each following line has the form `old: new`. Say it aloud as "old is renamed to new" and check it against what you know.

## A schema file is not enough

A file that passes the checklist is well-formed. It is still only a description. For a pipeline, there are two more steps.

First, apply the rename in a test: send a span with the old name through the pipeline and read the output with the `debug` exporter, as the earlier modules did. The new name must be present and, in a migration window, the old name must be present too.

Second, compare the translated names with a consumer. Open the dashboard or the alert rule that uses the name and check that it matches the output.

## Keep the file under review

Treat a schema file as code. Store it in version control, review changes to it, and add a test that reads it with the checks above. A change to the file should be as small as the change to the conventions it records, and it should add a new version section rather than edit an old one. A schema file for a version that already shipped must not change, because tools and data in the field depend on it.

## Repair the file in the playground

In the playground, the ConfigMap `schema-file` holds a file that fails several checks. Run the commands above, write down every failed item, fix the file with `kubectl edit configmap schema-file -n starfleet` and run the commands again until each check passes. The lab of this module asks you to do the same and grades the result.

## Checkpoints

- Why must a schema file list versions that have no changes?
- Which spelling is correct, `rename_attribute` or `rename_attributes`?
- Why should a released version section never be edited?

Answers: tools walk the versions in order and need each one to exist. `rename_attributes`. Data and tools in the field depend on it.

You can now read a schema file, apply its changes in both directions and review it with a short checklist. The lab puts the checklist to use on a file with several mistakes.

## Common pitfalls

> [!WARNING]
> - Do not trust a file only because it is valid YAML.
> - Do not delete an old version to make a file shorter.
> - Do not skip the test with a real span after a file passes the checklist.
