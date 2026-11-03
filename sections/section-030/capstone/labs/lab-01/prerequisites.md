# Prerequisites

- The `astrona` command-line tool, installed and working (`astrona check` passes).
- A container engine that kind can use (Podman or Docker) with about 2 GiB of free memory.
- `kubectl`.
- You can read the exporter queue and retry settings and the `memory_limiter` configuration.

The lab starts a single-node kind cluster (Kubernetes 1.35) with the example workloads in the `starfleet` and `observability` namespaces.
