---
estimated_duration: 30m
---

# Lab: Survive A Backend Outage With Retry And A Queue

Graded lab. **Status: UNTESTED.** It was built without booting the lab; run `astrona test -c .` before relying on it. Open risks: the exact output text of the OpenTelemetry Collector `debug` exporter, the metric labels of the Collector internal telemetry, and the component names of the pinned Collector release (`otel/opentelemetry-collector-contrib:0.164.0`).

A Collector exports to a backend with retry and the sending queue switched off, so telemetry sent during a short backend outage is lost. The task is in `question.md`; the walkthrough is in `solution.md`.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS076.git -c sections/section-030/module-01/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS076.git -c sections/section-030/module-01/labs/lab-01
astrona destroy ats-076-lab-030-01
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-queue-capacity.sh` | The exporter otlp_http/backend has a sending queue with capacity 5000 |
| `validate-outage-survived.sh` | A span sent while the backend is down reaches the backend after it returns |
