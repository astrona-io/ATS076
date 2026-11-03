---
estimated_duration: 20m
---

# Lab: Strip Baggage At The Public Edge

Graded lab. **Status: UNTESTED.** It was built without booting the lab; run `astrona test -c .` before relying on it. Open risks: the exact output text of the OpenTelemetry Collector `debug` exporter, the metric labels of the Collector internal telemetry, and the component names of the pinned Collector release (`otel/opentelemetry-collector-contrib:0.164.0`).

An edge proxy forwards the `baggage` header from untrusted public callers to the `probe` service. The task is in `question.md`; the walkthrough is in `solution.md`.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS076.git -c sections/section-010/module-02/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS076.git -c sections/section-010/module-02/labs/lab-01
astrona destroy ats-076-lab-010-02
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-public-baggage-removed.sh` | A baggage header sent to the public listener (port 80) does not reach the probe |
| `validate-public-traceparent-kept.sh` | A traceparent header sent to the public listener still reaches the probe |
| `validate-internal-baggage-kept.sh` | The internal listener (port 8081) still forwards baggage from trusted callers |
