---
estimated_duration: 30m
---

# Lab: Rename Legacy HTTP Attributes In The Pipeline

Graded lab. **Status: UNTESTED.** It was built without booting the lab; run `astrona test -c .` before relying on it. Open risks: the exact output text of the OpenTelemetry Collector `debug` exporter, the metric labels of the Collector internal telemetry, and the component names of the pinned Collector release (`otel/opentelemetry-collector-contrib:0.164.0`).

Older instrumentation sends the HTTP attribute names `http.method` and `http.status_code`; the backend queries use the stable names. The task is in `question.md`; the walkthrough is in `solution.md`.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS076.git -c sections/section-040/module-01/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS076.git -c sections/section-040/module-01/labs/lab-01
astrona destroy ats-076-lab-040-01
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-legacy-renamed.sh` | A span with http.method and http.status_code leaves with http.request.method and http.response.status_code |
| `validate-other-attributes-kept.sh` | Other attributes of the span stay unchanged |
| `validate-new-style-unchanged.sh` | A span that already uses the new names keeps its values |
