---
estimated_duration: 25m
---

# Lab: Find A Processor That Drops Too Much

Graded lab. **Status: UNTESTED.** It was built without booting the lab; run `astrona test -c .` before relying on it. Open risks: the exact output text of the OpenTelemetry Collector `debug` exporter, the metric labels of the Collector internal telemetry, and the component names of the pinned Collector release (`otel/opentelemetry-collector-contrib:0.164.0`).

A `filter` processor was written to drop health check spans, but the receiver accepts spans that never reach the exporter. The task is in `question.md`; the walkthrough is in `solution.md`.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS076.git -c sections/section-020/module-02/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS076.git -c sections/section-020/module-02/labs/lab-01
astrona destroy ats-076-lab-020-02
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-normal-span-kept.sh` | A span named POST /checkout reaches the debug exporter |
| `validate-health-span-dropped.sh` | A span named GET /healthz does not reach the debug exporter |
| `validate-metrics-endpoint-up.sh` | The internal metrics endpoint on port 8888 lists the receiver accepted spans metric |
