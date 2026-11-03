---
draft: true
exam_objectives:
  - Error Handling
---
# Summary

OTLP has two transports. OTLP/gRPC uses port 4317, and OTLP/HTTP uses port 4318 with the paths `/v1/traces`, `/v1/metrics` and `/v1/logs`. The Collector OTLP/HTTP exporter adds the signal path to its `endpoint` itself, so the endpoint must hold only the base URL. A full path in the endpoint creates a second path and a 404 from the destination.

A sender sorts every failure into two groups. Over HTTP, it retries 429, 502, 503 and 504 and treats all other 4xx and 5xx statuses as permanent. Over gRPC, it retries `CANCELLED`, `DEADLINE_EXCEEDED`, `ABORTED`, `OUT_OF_RANGE`, `UNAVAILABLE` and `DATA_LOSS`, and it retries `RESOURCE_EXHAUSTED` only when the server sends `RetryInfo`. A permanent error drops the data at once, and retry settings cannot help.

A partial success is a third case. The server answers with a success status and a body that names the number of rejected items and an error message. The sender must not retry, because the accepted items would be stored twice. No failed counter shows it, so the evidence is the log message and a difference between sent and stored items.

Servers can ask senders to wait with the `Retry-After` header or `RetryInfo`. The Collector spaces its retries with exponential backoff and jitter and gives up after `max_elapsed_time`. A drop line in the exporter log and a rising `otelcol_exporter_send_failed_spans` prove that data was lost, and the status code in the error text tells which group the failure belongs to.

Key facts:

- A 200 at the first Collector does not prove that data reached the backend.
- `max_elapsed_time: 0s` means retry without end.
- Counters restart at zero when the process restarts.

<!-- astrona:playground:destroy -->
