---
draft: true
exam_objectives:
  - Debugging Pipelines
---
# Sizing Queues And Persistent Storage

A queue that is too small refuses data during a short outage. A queue that is too large uses memory the Collector needs for other work. This part shows how to estimate a size from traffic and outage length, how to read the queue metrics, and how to keep the queue across a restart with persistent storage.

## Estimating a size

Start from three numbers:

| Number | Example |
| --- | --- |
| Batches per second that the exporter receives | 20 |
| Longest outage the queue must survive | 60 seconds |
| Memory a typical batch uses | 200 KiB |

The queue must hold the batches that arrive during the outage:

```
batches needed = batches per second x outage seconds
               = 20 x 60 = 1200
memory         = 1200 x 200 KiB = about 234 MiB
```

Two facts follow. The size in batches comes from the rate, not from the number of spans. The memory use comes from the size of a batch, and the batch processor setting `send_batch_max_size` limits it. Compare the memory result with the container limit, because a queue that can fill more memory than the container has leads to a kill instead of a refusal. The memory limiter, covered in the next module, is the second line of defence.

Because the number of batches depends on the batch processor, a change to its settings changes how long the queue lasts. Larger batches mean fewer batches per second, so the same queue size lasts longer, but each batch uses more memory.

## Metrics for the queue

Two gauges show the queue state:

| Metric | Meaning |
| --- | --- |
| `otelcol_exporter_queue_size` | Items in the queue now. |
| `otelcol_exporter_queue_capacity` | The configured maximum. |

Counters show the outcome: `otelcol_exporter_enqueue_failed_spans` rises when a batch is refused because the queue is full, and `otelcol_exporter_send_failed_spans` rises when sending fails after retries. Names, labels and a `_total` suffix depend on the version.

Reading the ratio of size to capacity during normal traffic shows the headroom. A queue that is often more than half full has too little room for an outage. A queue that stays near zero and has a very large capacity wastes memory.

<!-- astrona:playground:renew -->

```sh
kubectl -n starfleet exec deploy/shuttle -- curl -s http://otelcol.observability:8888/metrics | grep -E 'otelcol_exporter_queue_(size|capacity)'
```

Run the command in the playground after the lab change. The capacity line shows the value that you configured, which is a way to prove that the new configuration is the one running.

## A queue in memory does not survive a restart

When the Collector process stops, the memory of the queue is gone. An outage of the backend that overlaps with a restart of the Collector, for example a node drain, loses all queued batches. To keep them, the queue can use a storage extension.

The `file_storage` extension writes data to a directory. The exporter's queue refers to it by name:

```
extensions:
  file_storage/queue:
    directory: /var/lib/otelcol/queue
    create_directory: true

exporters:
  otlp_http/backend:
    sending_queue:
      enabled: true
      queue_size: 5000
      storage: file_storage/queue

service:
  extensions: [file_storage/queue]
```

Three points need care:

1. The extension must be listed under `service.extensions`. A defined extension that is not listed is not started, and the exporter then fails to start or has no storage.
2. The directory must exist and be writable by the user that runs the Collector. In Kubernetes, mount a volume at that path. An `emptyDir` volume survives a container restart but not a pod replacement. A PersistentVolumeClaim survives both.
3. Writing to disk is slower than memory, so the throughput of the queue is lower.

## What a persistent queue does after a restart

After a restart the Collector opens the same directory, finds the batches that were queued, and sends them. Batches that were in flight at the moment of the stop may be sent twice, because the Collector cannot know if the destination had stored them. A backend that stores spans by identifier ignores duplicates. A backend that counts every received span may count them twice.

The persistent queue protects against restarts of the Collector. It does not protect against loss of the disk, and it does not make the queue larger than `queue_size`.

## Order of work for a loss investigation

When spans are lost during backend outages, check in this order:

1. Is `retry_on_failure` enabled, and is the time limit longer than the outage?
2. Is `sending_queue` enabled, and is its size large enough for the outage?
3. Do the counters show enqueue failures? That means the queue was full.
4. Did the Collector restart during the outage? That points at persistent storage.

Each answer points at one setting, and each setting has a metric that proves it.

## Checkpoints

- The exporter gets 10 batches per second and the backend can be down for 2 minutes. What queue size covers it?
- `enqueue_failed_spans` rises during an outage. Which setting is too small?
- A persistent queue is configured and the extension is not in `service.extensions`. What happens?

Answers: 1200 batches. The queue size. The extension does not start, so the queue cannot use it and the Collector fails or runs without it, depending on the version.

You can now size a queue from a rate and an outage, read its metrics and keep it across a restart. The next module deals with the case where the Collector itself runs out of memory.

## Common pitfalls

> [!WARNING]
> - Do not size a queue in spans. The default unit is batches.
> - Do not make the queue larger than the memory of the container allows.
> - Do not list the storage in the exporter and forget the `service.extensions` entry.
> - Do not mount the queue directory on a path the Collector user cannot write.
