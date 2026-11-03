---
estimated_duration: 35m
---

# Capstone: Schema Management Capstone

Graded lab. **Status: UNTESTED.** It was built without booting the lab; run `astrona test -c .` before relying on it. Open risks: the exact output text of the OpenTelemetry Collector `debug` exporter, the metric labels of the Collector internal telemetry, and the component names of the pinned Collector release (`otel/opentelemetry-collector-contrib:0.164.0`).

Older instrumentation sends legacy attribute names; the pipeline must rename some and emit both names for another. The task is in `question.md`; the walkthrough is in `solution.md`.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS076.git -c sections/section-040/capstone/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS076.git -c sections/section-040/capstone/labs/lab-01
astrona destroy ats-076-capstone-040
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-http-renamed.sh` | http.method and http.status_code leave as http.request.method and http.response.status_code, without the legacy names |
| `validate-peer-dual-emitted.sh` | net.peer.name is kept and server.address is added with the same value |
| `validate-others-and-new-style-kept.sh` | Other attributes stay, and a span with only stable names keeps its values |
| `validate-evidence-recorded.sh` | The ConfigMap schema-evidence records the renamed and dual-emitted attributes and a UTC time |
