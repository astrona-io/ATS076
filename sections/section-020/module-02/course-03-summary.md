---
draft: true
exam_objectives:
  - Debugging Pipelines
---
# Summary

Every stage of a pipeline counts the items it handles. In a pipeline without sampling, the items accepted by the receiver must equal the items that leave each processor and the items the exporter sends, fails or still holds in its queue. A difference between two neighbouring numbers marks the stage that removed items. Counters are cumulative, so a test needs one reading before and one after.

The filter processor drops a span when any condition in its list is true. A condition names what to remove, so a condition written for the spans to keep removes every other span, and the Collector reports no error. A drop rule is tested with a span that must be dropped and a span that must pass. After a change, the Collector must restart to read the file.

Key facts:

- Compare neighbouring counters in pipeline order; the first drop locates the stage.
- A filter condition names the spans to drop.
- `error_mode: ignore` keeps data when a condition fails.
- Test a drop rule with both a kept and a dropped span.

<!-- astrona:playground:destroy -->
