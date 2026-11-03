---
estimated_duration: 35m
---

# Capstone: Context Propagation Capstone

Graded lab. **Status: UNTESTED.** It was built without booting the lab; run `astrona test -c .` before relying on it. Open risks: the exact output text of the OpenTelemetry Collector `debug` exporter, the metric labels of the Collector internal telemetry, and the component names of the pinned Collector release (`otel/opentelemetry-collector-contrib:0.164.0`).

Requests pass through an `edge` proxy and then a `gateway` proxy before they reach the `probe` service. The gateway removes trace context and the edge forwards baggage from public callers. The task is in `question.md`; the walkthrough is in `solution.md`.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS076.git -c sections/section-010/capstone/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS076.git -c sections/section-010/capstone/labs/lab-01
astrona destroy ats-076-capstone-010
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-traceparent-reaches-probe.sh` | traceparent sent to the edge reaches the probe through both proxies |
| `validate-tracestate-reaches-probe.sh` | tracestate sent to the edge reaches the probe through both proxies |
| `validate-baggage-removed-at-edge.sh` | baggage sent by a public caller does not reach the probe |
| `validate-chain-serves.sh` | The chain still serves requests and the original proxy images are unchanged |
| `validate-evidence-recorded.sh` | The ConfigMap propagation-evidence names the failing boundary and records the result |
