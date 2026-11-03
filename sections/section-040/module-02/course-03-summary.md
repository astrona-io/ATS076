---
draft: true
exam_objectives:
  - Debugging Pipelines
---
# Summary

A schema URL names the convention version that data claims to follow. It is metadata and does not prove the attribute names, and many backends do not translate names. Dashboards, alerts, stored queries and downstream rules all depend on names. A removed name breaks them, and a broken alert is quiet.

A dual emission window keeps both names for a period. The transform processor needs a copy statement for each direction, each with a where clause, and no delete. Spans from old services then gain the stable name, and spans from new services gain the legacy name. A mixed span needs a defined winner, which the order of the statements decides. The window has costs in span size and attribute count, and it needs a planned end, at which the legacy names are removed.

Key facts:

- Read real spans; a schema URL is not proof.
- Dual emission needs a copy in each direction and no delete.
- Prove the rule with old, new and mixed spans.
- Plan the end of the window.

<!-- astrona:playground:destroy -->
