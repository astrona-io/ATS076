---
estimated_duration: 20m
---

# Lab: Find The Receiver Missing From A Pipeline

Graded lab. **Status: UNTESTED.** It was built without booting the lab; run `astrona test -c .` before relying on it. Open risks: the exact output text of the OpenTelemetry Collector `debug` exporter, the metric labels of the Collector internal telemetry, and the component names of the pinned Collector release (`otel/opentelemetry-collector-contrib:0.164.0`).

An OpenTelemetry Collector defines an OTLP/HTTP receiver, but applications cannot send data to port 4318. The task is in `question.md`; the walkthrough is in `solution.md`.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS076.git -c sections/section-020/module-01/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS076.git -c sections/section-020/module-01/labs/lab-01
astrona destroy ats-076-lab-020-01
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-http-accepts-spans.sh` | The Collector accepts a span over OTLP/HTTP on port 4318 |
| `validate-span-in-debug-output.sh` | A span sent over OTLP/HTTP appears in the debug exporter output |
| `validate-collector-healthy.sh` | The health check endpoint on port 13133 answers 200 |
