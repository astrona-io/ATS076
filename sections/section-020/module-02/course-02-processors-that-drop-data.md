---
draft: true
exam_objectives:
  - Debugging Pipelines
---
# Processors That Drop Data

The counters named a processor as the stage that removes spans. This part explains how the processors that remove data decide what to remove, why a small mistake in a condition removes everything, and how to correct and check the rule.

## Processors that remove data on purpose

Most processors change items. A few exist to remove them:

- The `filter` processor drops items that match a condition.
- The `probabilistic_sampler` processor keeps a fixed share of traces and drops the rest.
- The `tail_sampling` processor waits for a whole trace, then keeps or drops it by policy.
- The `memory_limiter` processor refuses data when memory use is too high.
- The `transform` processor can drop an item when a statement fails, depending on its `error_mode`.

Removing data is the purpose of the first three. For them, a loss is correct when the rule is correct. The fault appears when the rule matches more than intended.

## How the filter processor decides

The `filter` processor holds lists of conditions per signal. For traces, the setting `trace_conditions` takes a list of OpenTelemetry Transformation Language conditions. If any condition in the list is true for a span, the span is dropped. All other spans pass.

```
processors:
  filter/health:
    error_mode: ignore
    trace_conditions:
      - span.name == "GET /healthz"
```

Read the rule as: drop the span when its name equals `GET /healthz`. The word that matters is drop. A condition describes what to remove, never what to keep. This is the most common source of faults, because people write the condition for the spans they want to keep.

An inverted condition looks like this:

```
trace_conditions:
  - span.name != "GET /healthz"
```

This rule drops every span whose name is not `GET /healthz`. Health checks pass through, and all useful spans are removed. The receiver counts spans as accepted, the processor outgoing counter stays at zero or at the number of health checks, and no error appears anywhere.

## Conditions in detail

A condition is a boolean expression. Frequent parts:

| Expression | Meaning |
| --- | --- |
| `span.name == "x"` | Span name equals the text. |
| `span.attributes["http.route"] == "/healthz"` | An attribute equals the text. |
| `IsMatch(span.name, "^GET /health.*")` | Span name matches a regular expression. |
| `span.kind == SPAN_KIND_SERVER` | Span kind is server. |
| `resource.attributes["service.name"] == "probe"` | Resource attribute equals the text. |

Several conditions in one list are combined with OR: a span that matches any one is dropped. To require two facts at once, join them in one condition with `and`:

```
- span.kind == SPAN_KIND_SERVER and span.name == "GET /healthz"
```

When an attribute does not exist on a span, a comparison with it is false, so a rule on an optional attribute drops only spans that have it. Add `!= nil` checks when a rule must be sure the attribute exists.

The `error_mode` setting decides what happens when a condition cannot be evaluated. The value `ignore` logs the error and treats the condition as not matching, so the span passes. The value `propagate` returns the error and the data is dropped. The value `silent` ignores errors without logging. For a drop rule, `ignore` is the safe choice, because an error should not remove data.

## Fix the rule in the playground

The playground Collector has a `filter/health` processor with an inverted condition, and the `shuttle` pod has `curl`.

<!-- astrona:playground:renew -->

Read the processor definition in the configuration:

```sh
kubectl -n observability get configmap otelcol-config -o jsonpath='{.data.config\.yaml}'
```

Find the `trace_conditions` list. Decide what the condition drops, in words, before you change anything. Then edit the ConfigMap:

```sh
kubectl -n observability edit configmap otelcol-config
```

Change the comparison so that the rule drops only `GET /healthz`. Restart the Collector so that it reads the file:

```sh
kubectl -n observability rollout restart deployment/otelcol
kubectl -n observability rollout status deployment/otelcol
```

Send one health span and one checkout span as in the previous part, and read the counters again. The receiver counter should rise by two, the processor outgoing counter by one, and the `debug` output should show only the checkout span.

## Check that the rule does only what you intend

A rule is correct when it drops what it should and keeps everything else. A test needs both sides:

1. A span that must be dropped. It must not appear in the output.
2. A span that must pass. It must appear with all its attributes.
3. A span that is close to the pattern, for example `GET /healthz/live` against an exact match. Decide on purpose whether it should be dropped.

Testing only the drop case passes an inverted rule that removes everything.

## Other causes of a lower outgoing count

If the condition is correct and the outgoing count is still lower, check these:

- A second processor after the first one, with a condition of its own.
- A `probabilistic_sampler` with a low percentage, which keeps only a share of traces by trace identifier.
- A `tail_sampling` policy that keeps only error traces.
- A `transform` processor with `error_mode: propagate` and a statement that fails for some spans.
- A pipeline that lists a processor twice.

The method does not change: find the first processor whose outgoing count is below its incoming count, read its rule, and compare it with one sample span.

## Checkpoints

- A filter has the condition `span.name == "GET /healthz"`. Which spans does it drop?
- A rule lists two conditions. A span matches only the second. Is it dropped?
- A condition fails to evaluate and `error_mode` is `ignore`. Does the span pass?

Answers: spans named exactly `GET /healthz`. Yes, a match on any condition drops the span. Yes, an ignored error means no match.

You can now read a drop rule, correct an inverted condition and prove the result with both a kept and a dropped span. The next step in debugging is the other end of the pipeline, where an exporter fails to deliver data it did accept.

## Common pitfalls

> [!WARNING]
> - Do not write a filter condition for the spans you want to keep. It names the spans to drop.
> - Do not test with only one kind of span. A correct drop test needs a span that passes as well.
> - Do not use `error_mode: propagate` on a drop rule unless you accept losing data on every error.
> - Do not forget the restart. The Collector keeps the old rule until the process starts again.
