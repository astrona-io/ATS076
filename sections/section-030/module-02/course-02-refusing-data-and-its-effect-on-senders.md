---
draft: true
exam_objectives:
  - Debugging Pipelines
---
# Refusing Data And Its Effect On Senders

When the memory limiter refuses data, the loss is not silent for everyone. The component in front of the limiter gets an error, and what it does with the error decides whether the data is lost or sent again later. This part follows a refusal from the processor back to the application and shows how to measure it.

## What a refusal looks like

The processor returns an error to the component that called it, which is the receiver. The error is a "data refused" error of a kind that the Collector marks as retryable. The receiver turns it into a response for the sender:

- On OTLP over HTTP, the response is a status such as 503 Service Unavailable, or 429 Too Many Requests, depending on the version.
- On OTLP over gRPC, the response is the status `UNAVAILABLE`.

The OTLP specification says that a client should retry these responses with exponential backoff. The SDK exporters in most languages do, with limits on the number of tries and the time. So a short refusal does not lose data when the sender retries. A refusal that lasts longer than the sender's retry limit loses it.

The data is therefore either held by the sender or lost at the sender. It is not lost inside the Collector, because the Collector never accepted it. That difference matters for the counters:

| Counter | Rises on a refusal |
| --- | --- |
| `otelcol_receiver_refused_spans` | Yes. The receiver could not pass the spans on. |
| `otelcol_receiver_accepted_spans` | No. |
| `otelcol_processor_refused_spans` | Yes on versions that report it, labelled with the limiter. |

A rise in refused spans is the signal that the limiter acts. If the counter rises while the memory is below the soft limit, check whether another component refuses data.

## Memory still grows when data is refused

A limiter that refuses data stops new data, but memory use does not fall at once. The Collector holds data in queues and in batches. Memory falls when the queues are sent and garbage is collected. This has two effects:

1. A queue that is large holds memory that the limiter cannot free. If the queue alone can reach the soft limit, the limiter refuses all new data while the queue slowly drains.
2. A slow exporter keeps queues full, so memory stays near the limit and refusals continue. The cause is then the exporter, not the traffic.

When refusals do not stop, look at the queue size gauge. If it is full, the memory limit is held by queued batches, and the fix is at the exporter: a destination that is reachable, a smaller queue, or more memory.

## Senders must be able to wait

Refusal is only useful if senders keep their data until they can try again. Check three things at the sender:

- The SDK exporter has retry enabled. Most do by default, but it can be switched off.
- The retry time is longer than a typical refusal.
- The SDK queue, usually the batch span processor, is large enough to hold spans while the exporter waits. When that queue is full, the SDK drops spans silently on the application side.

So a refusal at the Collector can become a loss inside the application process, where the Collector counters show nothing. A sign of this is that the application SDK logs show dropped spans while the Collector refused counters rise.

An agent and gateway layout also matters. When an agent Collector forwards to a gateway Collector and the gateway refuses, the agent's exporter retries from its own queue, so the pressure moves one step back along the path. A memory limiter on every Collector in the chain keeps each one safe.

## Test the effect in the playground

After you fix the order and the limits as the lab asks, you can show the effect of the limiter without a real spike by reading its settings and the refusal counters:

<!-- astrona:playground:renew -->

```sh
kubectl -n starfleet exec deploy/shuttle -- curl -s http://otelcol.observability:8888/metrics | grep -E 'otelcol_(receiver_refused_spans|processor_refused_spans|process_memory_rss)'
```

The line with `otelcol_process_memory_rss` shows the resident memory of the process in bytes. Compare it with the soft limit. Send a few spans, read it again, and note the difference. Run the check from the question again after the restart. A value near the soft limit while idle means that other components, such as a large queue, hold memory.

Do not try to fill memory in the playground. A test that crosses the limit is outside the scope of this exercise.

## What to do when refusals appear

Work through these steps:

1. Check whether the memory limit of the container is too low for the traffic. If the process is always near the soft limit, raise the container limit and both limiter values together.
2. Check the queues. If a queue is full, find out why the destination is slow.
3. Check the batch size. Very large batches use a lot of memory per item.
4. Check the senders. Make sure they retry and have room in their own queues.
5. Consider scaling out. A second Collector replica halves the load on each, if senders balance between them.

A limiter is a protection, not a capacity plan. Refusals that appear often mean the Collector is too small for the load.

## Checkpoints

- The limiter refuses data. Which side holds the refused spans?
- Refusals continue after the traffic falls. What is a likely cause?
- The Collector shows refused spans and the application logs show dropped spans. Where is the loss?

Answers: the sender, if it retries. A full queue that holds memory. In the application, where its own queue overflowed.

You can now explain what a refusal does to senders and find the cause when refusals persist. The next section deals with a different kind of fault: data that arrives complete but under names that consumers do not expect.

## Common pitfalls

> [!WARNING]
> - Do not read refused spans as lost spans. If the sender retries, the data is delayed.
> - Do not raise only the limiter values. The container limit must rise with them.
> - Do not overlook queues. They keep memory high after the traffic falls.
> - Do not test the limiter by exhausting memory in a shared environment.
