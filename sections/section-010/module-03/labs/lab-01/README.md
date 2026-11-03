---
estimated_duration: 20m
---

# Lab: Forward Every Trace Header Format Through A Gateway

Graded lab. **Status: UNTESTED.** It was built without booting the lab; run `astrona test -c .` before relying on it.

A gateway proxy in front of the `probe` service removes the B3 and Jaeger trace headers and also a security header. The task is in `question.md`; the walkthrough is in `solution.md`.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS076.git -c sections/section-010/module-03/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS076.git -c sections/section-010/module-03/labs/lab-01
astrona destroy ats-076-lab-010-03
```

## Checks

| Script | What it proves |
| --- | --- |
| `validate-b3-forwarded.sh` | The probe receives the b3 header and the X-B3 headers sent through the gateway |
| `validate-jaeger-forwarded.sh` | The probe receives the uber-trace-id header sent through the gateway |
| `validate-internal-debug-hidden.sh` | The gateway still removes x-internal-debug and still proxies |
