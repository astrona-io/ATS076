---
draft: true
exam_objectives:
  - Debugging Pipelines
---
# Summary

The semantic conventions define attribute names, values and meanings so that consumers can query data from many services. Names change between versions, for example http.method became http.request.method. During a migration the Collector receives both generations, and a consumer that queries one name sees only part of the data. Nothing fails; the spans are accepted and stored under different names.

The transform processor makes names uniform. A rename is a set followed by a delete_key, with a where clause that limits the copy to spans that have the legacy name. Without the clause, a span that already uses the stable name can lose its value. The error_mode ignore keeps data when a statement fails. The processor runs only when the pipeline lists it, and the Collector must restart to read the change. A test needs a legacy span, a stable span and a span with an unrelated attribute.

Key facts:

- Read real spans to learn which names a service sends.
- A rename is copy then delete.
- Limit the copy with a where clause.
- List the processor in the pipeline and restart the Collector.

<!-- astrona:playground:destroy -->
