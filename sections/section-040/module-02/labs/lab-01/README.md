---
estimated_duration: 25m
---

# Lab: Emit Both Attribute Names During A Migration

Graded lab. **Status: UNTESTED.** It was built without booting the lab; run `astrona test -c .` before relying on it. Open risks: the exact output text of the OpenTelemetry Collector `debug` exporter, the metric labels of the Collector internal telemetry, and the component names of the pinned Collector release (`otel/opentelemetry-collector-contrib:0.164.0`).

A pipeline renames the legacy HTTP attributes and deletes the old names, but old dashboards still query them. The task is in `question.md`; the walkthrough is in `solution.md`.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS076.git -c sections/section-040/module-02/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS076.git -c sections/section-040/module-02/labs/lab-01
astrona destroy ats-076-lab-040-02
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-old-source-has-both.sh` | A span sent with the legacy names leaves with the legacy and the stable names |
| `validate-new-source-has-both.sh` | A span sent with the stable names leaves with the stable and the legacy names |
| `validate-other-attributes-kept.sh` | Other attributes of the span stay unchanged |
