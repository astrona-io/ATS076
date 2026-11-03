---
draft: true
exam_objectives:
  - Debugging Pipelines
---
# Renaming Attributes With OTTL

The previous part showed that two generations of names reach the Collector. This part writes the rule that makes them uniform. The tool is the `transform` processor, which runs statements in the OpenTelemetry Transformation Language (OTTL) against every item that passes.

## The transform processor

The processor holds lists of statements per signal. For traces, the setting is `trace_statements`. Each statement runs against each span in order. A statement is a function call with an optional condition:

```
processors:
  transform/semconv:
    error_mode: ignore
    trace_statements:
      - set(span.attributes["http.request.method"], span.attributes["http.method"]) where span.attributes["http.method"] != nil
      - delete_key(span.attributes, "http.method")
```

The path `span.attributes["http.method"]` reads or writes one attribute of the current span. The prefix `span` names the kind of item, so the path says what it points at. Other prefixes exist for the resource, the scope, and for other signals. The statement list is flat: the prefix in each path, not a separate setting, selects the context. Check the documentation of the version you run, because older versions used a `context` field to give the same information, and a configuration written for one style fails on the other.

## The two functions used for a rename

| Function | Effect |
| --- | --- |
| `set(target, value)` | Writes the value to the target path. |
| `delete_key(map, "key")` | Removes the key from the map. |

A rename is a copy followed by a delete. There is no single rename function in this syntax, so two statements make one rename. The order matters: copy first, delete second. If the delete came first, the copy would read a missing value.

## The where clause

The `where` clause makes a statement run only when its condition is true. Without it, the statement for a span that has no `http.method` would run `set(span.attributes["http.request.method"], span.attributes["http.method"])`. The source path reads as nil, and the target is set to nil or the statement fails, depending on the version. Either way, a correct `http.request.method` from a new service can be overwritten.

The clause `where span.attributes["http.method"] != nil` makes the statement act only on spans that have the legacy attribute. Spans from new services skip the statement and keep their values. The same applies to the delete, but `delete_key` on a missing key does nothing, so it needs no condition.

The result for the three kinds of span:

| Span carries | After the rule |
| --- | --- |
| Only `http.method` | Only `http.request.method`, same value. |
| Only `http.request.method` | Unchanged. |
| Both | `http.request.method` is overwritten with the legacy value, and `http.method` is removed. |

The third row is a decision. If both names are present and differ, the legacy value wins in this rule. To let the stable value win, add a condition `and span.attributes["http.request.method"] == nil`.

## Error handling

The `error_mode` setting controls what happens when a statement fails:

| Value | Behaviour |
| --- | --- |
| `ignore` | Log the error and continue with the next statement. |
| `silent` | Continue and do not log. |
| `propagate` | Return the error, and the data is dropped. |

For a rename, `ignore` is the right choice. A single span with an unexpected shape should not remove data.

## The processor must be in the pipeline

Defining `transform/semconv` creates nothing that runs. The traces pipeline must list it:

```
service:
  pipelines:
    traces:
      receivers: [otlp]
      processors: [memory_limiter, transform/semconv]
      exporters: [debug]
```

This is the same lesson as the first section: a defined processor that is not listed is silent. A symptom is that the output still shows `http.method` after the change. The memory limiter, if there is one, stays first.

## Apply and prove the rename in the playground

<!-- astrona:playground:renew -->

Edit the Collector configuration, add the processor and list it in the pipeline:

```sh
kubectl -n observability edit configmap otelcol-config
```

Restart the Collector and wait for it:

```sh
kubectl -n observability rollout restart deployment/otelcol
kubectl -n observability rollout status deployment/otelcol
```

Send the legacy span from the previous part, then read the log:

```sh
kubectl -n observability logs deploy/otelcol --tail=40
```

The span should show `http.request.method` and `http.response.status_code` and should not show the legacy names. Now send a span that already uses the stable names and check that its values are unchanged. Both tests are needed. A rule that passes only the first test may overwrite stable values.

Finally send a span with an unrelated attribute, such as `app.order_id`. It must be unchanged. A rename rule should touch only the attributes it names.

## When a rename is not enough

A rename covers the key. It does not cover:

- A change of value format, such as a method name case or a status text.
- A key that was split into several, such as `http.target` into `url.path` and `url.query`. This needs functions that parse the value.
- Attributes that are not on spans, such as log record or metric attributes. Those use their own paths and statement lists.
- Consumers that cannot change. They need the old name to remain, which the next module handles.

## Checkpoints

- Why does a rename need two statements?
- What does `where span.attributes["http.method"] != nil` protect?
- The log still shows `http.method` after the change. Name two causes.

Answers: the syntax has copy and delete, not rename. A span that already has the stable name, from being overwritten. The processor is not listed in the pipeline, or the Collector was not restarted.

You can now write and prove a rename rule. The next module covers how to roll it out without breaking consumers that still read the old names.

## Common pitfalls

> [!WARNING]
> - Do not write the delete before the copy. The copy then reads a missing value.
> - Do not leave out the `where` clause. A span without the legacy name can lose its stable value.
> - Do not define the processor and forget the pipeline list.
> - Do not mix the path style of one version with a configuration for another. Check the documentation of the version you run.
