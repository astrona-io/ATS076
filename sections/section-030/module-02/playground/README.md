# The Memory Limiter - Playground

- **Slug:** ats-076-playground-030-02
- **Author:** Paris Nakita Kejser
- **Type:** Astrona playground - clean environment, no task, no grading
- **Status:** built untested (never booted by the author)

A sandbox for the memory limiter. Nothing to submit.

## Run it

```sh
astrona run -c .
astrona destroy ats-076-playground-030-02
```

`astrona destroy` takes the environment name (`metadata.name`), not the config path.

## Layout

| Path | Purpose |
| --- | --- |
| `config.yaml` | Environment definition (runtime, preloaded images, starting manifests) |
| `manifests/start.yaml` | Namespaces, the example workloads and the Collector configuration |
| `docs/overview.md` | What the environment contains and ideas to try |
