# Question

Solve this question on: `terminal`

The Collector `otelcol` in `observability` runs with a container memory limit of `256Mi`. Its traces pipeline has two processors: `memory_limiter` and `attributes/env`, which adds the attribute `deployment.environment=lab` to every span. During a traffic spike the container was killed for running out of memory, although a `memory_limiter` is configured.

1. Read the processors of the traces pipeline and decide why the `memory_limiter` could not protect the process.
2. Change the order so that the `memory_limiter` runs first. Keep the processors list on one line, in flow style.
3. Change `limit_mib` and `spike_limit_mib` so that the hard limit fits the container, with about 50 MiB of room for the rest of the process. `spike_limit_mib` must stay below `limit_mib`.
4. Keep the `attributes/env` processor in the pipeline.

`kubectl` already points at the cluster. The configuration is the key `config.yaml` of the ConfigMap `otelcol-config`. Restart the Deployment after a change. The `shuttle` pod in `starfleet` has `curl`.
