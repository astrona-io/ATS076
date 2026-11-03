---
estimated_duration: 35m
---

# Capstone: Debugging Pipelines Capstone

Graded lab. **Status: UNTESTED.** It was built without booting the lab; run `astrona test -c .` before relying on it. Open risks: the exact output text of the OpenTelemetry Collector `debug` exporter, the metric labels of the Collector internal telemetry, and the component names of the pinned Collector release (`otel/opentelemetry-collector-contrib:0.164.0`).

A Collector has three faults at three stages: a receiver that does not start, a processor that drops too much and an extension that is not enabled. The task is in `question.md`; the walkthrough is in `solution.md`.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS076.git -c sections/section-020/capstone/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS076.git -c sections/section-020/capstone/labs/lab-01
astrona destroy ats-076-capstone-020
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-http-accepts-spans.sh` | The Collector accepts a span over OTLP/HTTP on port 4318 |
| `validate-normal-span-kept.sh` | A span named POST /checkout reaches the debug exporter |
| `validate-health-span-dropped.sh` | A span named GET /healthz does not reach the debug exporter |
| `validate-health-endpoint-up.sh` | The health check endpoint on port 13133 answers 200 |
| `validate-evidence-recorded.sh` | The ConfigMap pipeline-evidence records one finding per stage and a UTC time |
