# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check. This lab was built without running it, so the text describes what you should see instead of printing output.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS076.git -c sections/section-020/module-03/labs/lab-01
```

## Step 1: Observe the failure

```sh
kubectl -n starfleet exec deploy/shuttle -- curl -s -o /dev/null -w '%{http_code}\n' --max-time 5 http://otelcol.observability:55679/debug/pipelinez
```

The request does not return 200. Nothing answers on the port.

## Step 2: Read the configuration

```sh
kubectl -n observability get configmap otelcol-config -o jsonpath='{.data.config\.yaml}'
```

Two problems show up. The list `service.extensions` has only `health_check`, so `zpages` and `pprof` never start. The endpoints of both extensions use `localhost`, so even a started extension would refuse connections from another pod.

## Step 3: Fix both and restart

```sh
kubectl -n observability edit configmap otelcol-config
```

Change `service.extensions` to `[health_check, zpages, pprof]`. Change the endpoints to `0.0.0.0:55679` and `0.0.0.0:1777`. Then restart the Collector:

```sh
kubectl -n observability rollout restart deployment/otelcol
kubectl -n observability rollout status deployment/otelcol
```

Repeat the request from step 1. It now returns 200. Request `http://otelcol.observability:1777/debug/pprof/` the same way.

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS076.git -c sections/section-020/module-03/labs/lab-01 --keep
```

All checks pass.
