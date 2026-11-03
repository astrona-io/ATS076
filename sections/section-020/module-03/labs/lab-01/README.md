---
estimated_duration: 20m
---

# Lab: Reach The Collector Diagnostic Pages

Graded lab. **Status: UNTESTED.** It was built without booting the lab; run `astrona test -c .` before relying on it. Open risks: the exact output text of Collector components and the component names of the pinned Collector release (`otel/opentelemetry-collector-contrib:0.164.0`).

The Collector defines the zpages and pprof extensions, but they cannot be reached. The task is in `question.md`; the walkthrough is in `solution.md`.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS076.git -c sections/section-020/module-03/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS076.git -c sections/section-020/module-03/labs/lab-01
astrona destroy ats-076-lab-020-03
```

## Checks

| Script | What it proves |
| --- | --- |
| `validate-zpages-reachable.sh` | The zPages pipelinez page answers 200 from another pod |
| `validate-pprof-reachable.sh` | The pprof index answers 200 from another pod |
| `validate-collector-still-works.sh` | The health check answers 200 and the Collector still accepts a span |
