---
draft: true
exam_objectives:
  - Debugging Pipelines
---
# Summary

The memory_limiter processor measures the memory use of the process at a fixed interval and refuses new data when the use passes the soft limit, which is limit_mib minus spike_limit_mib. Above the hard limit, limit_mib, it also forces garbage collection. The hard limit must be below the container limit with room for the runtime, or the process is killed first.

Processors run in list order, so the memory_limiter must be first. A processor before it handles data that the limiter should have refused. The configuration is valid in either order, and the fault shows only under a spike. A refusal returns a retryable error to the sender. A sender that retries holds the data, and a sender that cannot is the place where data is lost. Memory does not fall at once after a refusal, because queues keep it. Frequent refusals mean the Collector is too small.

Key facts:

- Soft limit equals limit_mib minus spike_limit_mib.
- The hard limit must be below the container memory limit.
- The memory_limiter is the first processor.
- A refusal is a retryable error for the sender, not a loss in the Collector.

<!-- astrona:playground:destroy -->
