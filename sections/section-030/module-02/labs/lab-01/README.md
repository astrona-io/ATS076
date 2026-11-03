---
estimated_duration: 25m
---

# Lab: Order And Size The Memory Limiter

Graded lab. **Status: UNTESTED.** It was built without booting the lab; run `astrona test -c .` before relying on it. Open risks: the exact output text of the OpenTelemetry Collector `debug` exporter, the metric labels of the Collector internal telemetry, and the component names of the pinned Collector release (`otel/opentelemetry-collector-contrib:0.164.0`).

A Collector has a `memory_limiter` that sits last in the pipeline and has a limit larger than the memory of its container. The task is in `question.md`; the walkthrough is in `solution.md`.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS076.git -c sections/section-030/module-02/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS076.git -c sections/section-030/module-02/labs/lab-01
astrona destroy ats-076-lab-030-02
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-memory-limiter-first.sh` | memory_limiter is the first processor of the traces pipeline |
| `validate-limit-fits-container.sh` | limit_mib is between 1 and 200 and spike_limit_mib is below limit_mib |
| `validate-env-attribute-kept.sh` | Spans still get the attribute deployment.environment=lab and are accepted |
