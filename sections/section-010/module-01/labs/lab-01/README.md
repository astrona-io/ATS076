---
estimated_duration: 20m
---

# Lab: Restore Trace Context Through A Gateway

Graded lab. **Status: UNTESTED.** It was built without booting the lab; run `astrona test -c .` before relying on it. Open risks: the exact output text of the OpenTelemetry Collector `debug` exporter, the metric labels of the Collector internal telemetry, and the component names of the pinned Collector release (`otel/opentelemetry-collector-contrib:0.164.0`).

A gateway proxy in front of the `probe` service removes the W3C Trace Context headers from every request. The task is in `question.md`; the walkthrough is in `solution.md`.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS076.git -c sections/section-010/module-01/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS076.git -c sections/section-010/module-01/labs/lab-01
astrona destroy ats-076-lab-010-01
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-traceparent-forwarded.sh` | The probe receives the traceparent header sent through the gateway |
| `validate-tracestate-forwarded.sh` | The probe receives the tracestate header sent through the gateway |
| `validate-gateway-still-proxies.sh` | The gateway still serves requests and runs its original image |
