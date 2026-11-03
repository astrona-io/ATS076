---
draft: true
exam_objectives:
  - Debugging Pipelines
---
# Summary

An exporter receives batches from the batch processor. With a sending queue, a batch waits until a sender takes it. When a call fails with a retryable error, the retry logic waits with growing intervals and tries again until the time limit is used up. Then the batch is dropped and the spans are counted as failed. An error that marks the request as wrong is permanent, and the batch is dropped at once. With retry and queue switched off, a short outage loses data.

The queue size counts the unit of the sizer, by default batches, not spans. A size follows from the batches per second multiplied by the outage length, and the memory use from the size of a batch. When the queue is full, the exporter refuses batches and counts them as enqueue failures. A queue in memory does not survive a restart. The file_storage extension keeps it on disk, but only when the extension is listed under service.extensions and the directory is writable.

Key facts:

- Retry and queue are settings that can be switched off.
- Queue size counts batches by default.
- Enqueue failures mean a full queue; send failures mean exhausted retries.
- Persistent storage needs a listed extension and a writable volume.

<!-- astrona:playground:destroy -->
