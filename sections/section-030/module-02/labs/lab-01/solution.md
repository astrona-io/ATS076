# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. This lab was built without running it, so the text describes what you should see instead of printing output.

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS076.git -c sections/section-030/module-02/labs/lab-01
```

## Step 1: Read the pipeline and the limits

```sh
kubectl -n observability get configmap otelcol-config -o jsonpath='{.data.config\.yaml}'
kubectl -n observability get deployment otelcol -o jsonpath='{.spec.template.spec.containers[0].resources.limits.memory}'
```

The pipeline is `processors: [attributes/env, memory_limiter]`, so data passes through `attributes/env` before the memory limiter can refuse it. The `limit_mib` is `4000`, but the container has only `256Mi`: the container runtime kills the process long before the limiter acts.

## Step 2: Fix order and size

```sh
kubectl -n observability edit configmap otelcol-config
```

Set `processors: [memory_limiter, attributes/env]`, `limit_mib: 150` and `spike_limit_mib: 30`. The soft limit is then 120 MiB, and the process stays below the container limit. Restart:

```sh
kubectl -n observability rollout restart deployment/otelcol
kubectl -n observability rollout status deployment/otelcol
```

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS076.git -c sections/section-030/module-02/labs/lab-01
```

All three checks pass.
