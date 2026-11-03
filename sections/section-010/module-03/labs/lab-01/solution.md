# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check. This lab was built without running it, so the text describes what you should see instead of printing output.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS076.git -c sections/section-010/module-03/labs/lab-01
```

## Step 1: Send one request with every format

```sh
kubectl -n starfleet exec deploy/shuttle -- curl -s http://gateway.starfleet/headers -H 'b3: 80f198ee56343ba864fe8b2a57d3eff7-e457b5a2e4d86bd1-1' -H 'x-b3-traceid: 80f198ee56343ba864fe8b2a57d3eff7' -H 'x-b3-spanid: e457b5a2e4d86bd1' -H 'x-b3-sampled: 1' -H 'uber-trace-id: 80f198ee56343ba864fe8b2a57d3eff7:e457b5a2e4d86bd1:0:1' -H 'x-internal-debug: on' -H 'x-request-check: present'
```

The echo contains `X-Request-Check` and none of the other headers. The echo is therefore reliable, and the gateway removes all the others.

## Step 2: Read the rules

```sh
kubectl -n starfleet get configmap gateway-conf -o jsonpath='{.data.nginx\.conf}'
```

Six `proxy_set_header` lines set a header to an empty string. Five of them hide trace headers: `b3`, `x-b3-traceid`, `x-b3-spanid`, `x-b3-sampled` and `uber-trace-id`. The sixth, `x-internal-debug`, is a security rule.

## Step 3: Remove the five trace rules and restart

```sh
kubectl -n starfleet edit configmap gateway-conf
```

Delete the five lines for the trace headers. Keep the `proxy_pass` line, the `Host` line and the `x-internal-debug` line. Then restart the gateway:

```sh
kubectl -n starfleet rollout restart deployment/gateway
kubectl -n starfleet rollout status deployment/gateway
```

Send the request from step 1 again. The echo now contains the B3 headers and `Uber-Trace-Id`, and it still does not contain `X-Internal-Debug`.

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS076.git -c sections/section-010/module-03/labs/lab-01 --keep
```

All three checks pass.
