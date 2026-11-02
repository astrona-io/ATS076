---
draft: true
exam_objectives:
- Context Propagation
---
# Summary

Propagation diagnosis follows the outgoing context, carrier preservation, receiver extraction and local execution scope. A successful business request can still lose tracing relationships. Sampling and instrumentation gaps are different causes of absent spans, while asynchronous work can require explicit context or links. Incoming identifiers remain untrusted correlation data. Repairing a graph means restoring the real causal contract, not fabricating parents or treating a trace ID as authority.
