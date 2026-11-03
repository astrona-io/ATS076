---
estimated_duration: 20m
---

# Lab: Fix An Exporter That Gets A Permanent Error

Graded lab. **Status: UNTESTED.** It was built without booting the lab; run `astrona test -c .` before relying on it. Open risks: the exact output text of Collector components and the component names of the pinned Collector release (`otel/opentelemetry-collector-contrib:0.164.0`).

Spans that the Collector accepts never reach the backend, and the exporter drops them. The task is in `question.md`; the walkthrough is in `solution.md`.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS076.git -c sections/section-030/module-03/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS076.git -c sections/section-030/module-03/labs/lab-01
astrona destroy ats-076-lab-030-03
```

## Checks

| Script | What it proves |
| --- | --- |
| `validate-span-reaches-backend.sh` | A span sent to the Collector reaches the backend |
| `validate-no-failed-spans.sh` | The exporter reports no failed spans |
| `validate-pipeline-intact.sh` | The exporter, the debug exporter and the backend are still in place |
