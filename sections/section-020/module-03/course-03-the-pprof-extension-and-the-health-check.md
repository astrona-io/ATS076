---
draft: true
exam_objectives:
  - Debugging Pipelines
---
# The pprof Extension And The Health Check

Two extensions answer very different questions. The `pprof` extension answers why the Collector process uses so much CPU or memory. The `health_check` extension answers whether the process is up. This part explains both, what each one can and cannot prove and how to use them without opening risky ports.

## The pprof extension

The Collector is a Go program. Go has a built-in profiler named `pprof`. A profile is a recording of where a running program spends CPU time or holds memory. The `pprof` extension serves the Go profiler on an HTTP port.

```yaml
extensions:
  pprof:
    endpoint: localhost:1777
service:
  extensions: [pprof]
```

The default endpoint is `localhost:1777`. The index page is at `/debug/pprof/`. The profiles that matter most are:

- `/debug/pprof/profile`: a CPU profile. By default it samples for 30 seconds. You can change the duration with the query parameter `seconds`.
- `/debug/pprof/heap`: the memory that the process has allocated and still holds.
- `/debug/pprof/goroutine`: the stacks of all goroutines. Goroutines are the lightweight threads of a Go program. A count that keeps growing points at a leak or at a blocked component.

The extension has two optional fields, `block_profile_fraction` and `mutex_profile_fraction`, which turn on profiling of blocked goroutines and of lock contention. Both are off by default because they cost CPU.

## Read a profile

A profile is binary data. You read it with the `go tool pprof` command on your machine, which needs a Go installation. To open a heap profile of the Collector through a port-forward:

<!-- astrona:playground:renew -->

```sh
kubectl -n observability port-forward deploy/otelcol 1777:1777
```

```sh
go tool pprof -top http://localhost:1777/debug/pprof/heap
```

The `-top` option prints the functions that hold the most memory, with their share of the total. A component that holds an unexpected share shows up here. For example, a queue that is larger than planned appears as memory held by the exporter code. A profile is evidence for the memory question that the memory limiter module raises, and the Collector log then tells you which limit acted.

Profiles can contain internal function names and, in rare cases, memory content. Treat them as internal data and do not attach them to a public issue without a check.

## The health check extension

The `health_check` extension serves one HTTP endpoint. A request returns the status 200 when the Collector is running and a 5xx status when it is not.

```yaml
extensions:
  health_check:
    endpoint: 0.0.0.0:13133
```

The default port is 13133. In Kubernetes, you point the liveness and readiness probes of the Collector container to this endpoint. The kubelet then restarts a Collector that does not answer and keeps a Collector that is not ready out of Service endpoints.

## What a healthy answer proves

A 200 from the health check proves that the process runs and the extension answers. It does not prove that data flows. A Collector whose pipeline has no receiver still answers 200. A Collector whose exporter fails every request still answers 200.

This is why the earlier modules combine the health check with the internal metrics. The health check tells you the process is alive. The counters for accepted and sent items tell you whether the pipeline works.

## Security of diagnostic ports

The three extensions of this module open ports with a lot of information. The `pprof` port can slow the process by starting a profile. Use these rules:

- Keep the default `localhost` binding in production and use `kubectl port-forward` when you need access.
- If you must bind to `0.0.0.0`, restrict who can connect, for example with a Kubernetes NetworkPolicy.
- Remove the extension from `service.extensions` when you no longer need it. A removed extension does not listen.

## Checkpoints

- Which `pprof` path gives the stacks of all goroutines?
- The health check answers 200 and no data reaches the backend. Is that a contradiction?
- Why is `localhost` a good default for the `pprof` endpoint?

Answers: `/debug/pprof/goroutine`. No. The health check shows that the process runs, not that data flows. The profiler can slow the process and exposes internal details, so only the pod itself can connect.

You now know what each of the three extensions can show. The last part brings them together with the logs, the metrics and the debug exporter, and gives a way to choose the right tool for a question.

## Common pitfalls

> [!WARNING]
> - Do not use a 200 from the health check as proof that data flows.
> - Do not leave a CPU profile running on a loaded Collector without need. It adds load.
> - Do not run `go tool pprof` against an endpoint that is not forwarded. The connection refuses.
