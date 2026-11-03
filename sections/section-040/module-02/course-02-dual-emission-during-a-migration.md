---
draft: true
exam_objectives:
  - Debugging Pipelines
---
# Dual Emission During A Migration

During a migration window every span must carry the legacy name and the stable name with the same value, whichever generation of service produced it. This part builds that rule with the transform processor, explains why it needs a statement for each direction, and shows how to prove it with three kinds of span.

## What the rule must do

A span can arrive in three shapes:

| Shape | Carries |
| --- | --- |
| Old service | `http.method` only |
| New service | `http.request.method` only |
| Mixed | Both names |

After the rule, every shape must carry both names with equal values. That needs two copy statements, one for each direction, and no delete.

```
processors:
  transform/semconv:
    error_mode: ignore
    trace_statements:
      - set(span.attributes["http.request.method"], span.attributes["http.method"]) where span.attributes["http.method"] != nil
      - set(span.attributes["http.method"], span.attributes["http.request.method"]) where span.attributes["http.request.method"] != nil
      - set(span.attributes["http.response.status_code"], span.attributes["http.status_code"]) where span.attributes["http.status_code"] != nil
      - set(span.attributes["http.status_code"], span.attributes["http.response.status_code"]) where span.attributes["http.response.status_code"] != nil
```

Read the first two statements together. The first fills the stable name from the legacy one. The second fills the legacy name from the stable one. For an old service, the first statement creates the stable name, and the second then copies it back onto the legacy name, which is a harmless write of the same value. For a new service, the first statement is skipped by its `where` clause and the second creates the legacy name.

## Why the order of statements matters

Statements run in order, and each one sees the result of the one before it. The pair above is safe in either order for the shapes in the table, because the value is the same on both sides after the first statement that applies.

The mixed shape is a decision again. When both names are present with different values, the first statement overwrites the stable value with the legacy one, and the second then copies it back. The legacy value wins. If you want the stable value to win, swap the two statements. The rule must have a defined winner, and a test span should prove it.

A common mistake is to write only the legacy-to-stable statement and to keep the delete removed. Old services then work, but spans from new services still lack the legacy name, so old dashboards show only part of the traffic. The migration looks done on the test span from an old service and fails on real traffic.

## Do not delete in the window

A delete statement from the earlier rename must go. With `delete_key(span.attributes, "http.method")` in the list, the legacy name is removed right after it is written. The two copy statements then end in a state that has only the stable name, which is the fault that the lab starts from.

Also check the end of the window. When all consumers have moved, the second statement of each pair is removed and a delete is added, and the processor returns to a plain rename. Write that change as a planned step with a date.

## Extending the rule to more names

Each pair of names needs its own two statements. For an attribute `net.peer.name` and its stable name `server.address`, the pair is:

```
- set(span.attributes["server.address"], span.attributes["net.peer.name"]) where span.attributes["net.peer.name"] != nil
- set(span.attributes["net.peer.name"], span.attributes["server.address"]) where span.attributes["server.address"] != nil
```

The statements are repetitive, which is the reason to generate them from a list of name pairs when there are many. Review the result with a diff, because one wrong key causes an overwrite of a different attribute.

Where a name has no direct counterpart, such as one legacy name that became two stable names, dual emission needs functions that split the value, and the result should be tested carefully. If a conversion is not exact, decide whether to emit it at all.

## Build and prove the rule in the playground

<!-- astrona:playground:renew -->

Open the configuration and change the statements:

```sh
kubectl -n observability edit configmap otelcol-config
```

Restart and wait:

```sh
kubectl -n observability rollout restart deployment/otelcol
kubectl -n observability rollout status deployment/otelcol
```

Send three spans, one for each shape, with different span names so that you can tell them apart in the log. A span from an old service carries `http.method` and `http.status_code`. A span from a new service carries `http.request.method` and `http.response.status_code`. A mixed span carries all four, with different values. Use the request body format from the first part of this module, and a new trace identifier for each.

Read the log:

```sh
kubectl -n observability logs deploy/otelcol --tail=80
```

Check each span:

1. The old span has both method names with the same value.
2. The new span has both method names with the same value.
3. The mixed span has equal values, and the winner is the one you chose.
4. Unrelated attributes are unchanged on every span.

A span that fails one check shows which statement or which `where` clause is wrong.

## Costs to watch

Dual emission doubles the attributes it covers. Watch two things in a window:

- The size of exported data. Use the exporter byte counters if your version has them.
- The attribute count of a span. Backends have limits on the number of attributes and the length of values, and a span over the limit can be truncated or rejected.

If either is a problem, shorten the window or limit the rule to the attributes that consumers need.

## Checkpoints

- Why does a window need a statement for each direction?
- A rule keeps the `delete_key` lines and has two copy statements. What do consumers see?
- Which test span finds a wrong winner?

Answers: spans from new services lack the legacy name otherwise. Only the stable names, since the delete runs after the copy. The mixed span with different values.

You can now build and prove a dual emission rule, and you know how the window ends. That completes the tools for finding and fixing the four kinds of fault in this course: lost context, a pipeline that does not run, data that is lost and data that arrives under the wrong names.

## Common pitfalls

> [!WARNING]
> - Do not copy in one direction only. Spans from new services then lack the legacy name.
> - Do not keep the delete statements in the window.
> - Do not leave the winner of a mixed span undefined. Test it.
> - Do not open a window without a planned step that closes it.
