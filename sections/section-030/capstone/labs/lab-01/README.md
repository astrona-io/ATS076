---
estimated_duration: 40m
---

# Capstone: Error Handling Capstone

Graded lab. **Status: UNTESTED.** It was built without booting the lab; run `astrona test -c .` before relying on it. Open risks: the exact output text of the OpenTelemetry Collector `debug` exporter, the metric labels of the Collector internal telemetry, and the component names of the pinned Collector release (`otel/opentelemetry-collector-contrib:0.164.0`).

A Collector loses telemetry in three ways: no retry, no queue and a memory limiter that cannot work. The task is in `question.md`; the walkthrough is in `solution.md`.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS076.git -c sections/section-030/capstone/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS076.git -c sections/section-030/capstone/labs/lab-01
astrona destroy ats-076-capstone-030
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-memory-limiter-first.sh` | memory_limiter is the first processor of the traces pipeline |
| `validate-limit-fits-container.sh` | limit_mib is between 1 and 200 and spike_limit_mib is below limit_mib |
| `validate-queue-capacity.sh` | The exporter otlp_http/backend has a sending queue with capacity 5000 |
| `validate-queue-persistent.sh` | The sending queue stores its batches with the file_storage/queue extension |
| `validate-outage-survived.sh` | A span sent while the backend is down reaches the backend after it returns |
| `validate-evidence-recorded.sh` | The ConfigMap loss-evidence records retry, queue and memory decisions and a UTC time |
