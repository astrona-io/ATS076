# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check. This lab was built without running it, so the text describes what you should see instead of printing output.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS076.git -c sections/section-010/module-01/labs/lab-01
```

`astrona submit` right after the start shows one check that already passes: `gateway-still-proxies`. It stays your guard while you fix the configuration.

## Step 1: Observe what the probe receives

Send a request with a `traceparent` header through the gateway:

```sh
kubectl -n starfleet exec deploy/shuttle -- curl -s http://gateway.starfleet/headers -H 'traceparent: 00-0af7651916cd43dd8448eb211c80319c-b7ad6b7169203331-01'
```

The echoed headers do not contain `Traceparent`. The request crossed the gateway, so the gateway removed it.

## Step 2: Find the lines that remove the context

```sh
kubectl -n starfleet get configmap gateway-conf -o jsonpath='{.data.nginx\.conf}'
```

Two `proxy_set_header` lines set `traceparent` and `tracestate` to an empty string. nginx does not send a header whose value is empty, so these lines delete the headers. nginx forwards all other request headers by default, so no line is needed to forward them.

## Step 3: Remove the lines and restart

```sh
kubectl -n starfleet edit configmap gateway-conf
```

Delete the two lines that start with `proxy_set_header traceparent` and `proxy_set_header tracestate`. Keep the `proxy_pass` and `Host` lines. Then restart the gateway:

```sh
kubectl -n starfleet rollout restart deployment/gateway
kubectl -n starfleet rollout status deployment/gateway
```

Send the request from step 1 again. The echoed headers now contain `Traceparent` with the same trace id.

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS076.git -c sections/section-010/module-01/labs/lab-01 --keep
```

All three checks pass.
