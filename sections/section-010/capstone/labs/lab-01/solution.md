# Solution

Solve this lab on `terminal`. This lab was built without running it, so the text describes what you should see instead of printing output.

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS076.git -c sections/section-010/capstone/labs/lab-01
```

## Step 1: Find the hop that removes the context

Ask the `gateway` directly, then the `edge`:

```sh
kubectl -n starfleet exec deploy/shuttle -- curl -s http://gateway.starfleet/headers -H 'traceparent: 00-0af7651916cd43dd8448eb211c80319c-b7ad6b7169203331-01'
kubectl -n starfleet exec deploy/shuttle -- curl -s http://edge.starfleet/headers -H 'traceparent: 00-0af7651916cd43dd8448eb211c80319c-b7ad6b7169203331-01'
```

Neither echo has `Traceparent`. Because the request to the `gateway` alone already loses the header, the gateway removes it. Read its configuration:

```sh
kubectl -n starfleet get configmap gateway-conf -o jsonpath='{.data.nginx\.conf}'
```

Two `proxy_set_header` lines set `traceparent` and `tracestate` to an empty value. Remove them with `kubectl -n starfleet edit configmap gateway-conf`.

## Step 2: Drop baggage at the edge

Run `kubectl -n starfleet edit configmap edge-conf` and add `proxy_set_header baggage "";` below the `Host` line of the only `server` block.

## Step 3: Restart and check

```sh
kubectl -n starfleet rollout restart deployment/gateway deployment/edge
kubectl -n starfleet rollout status deployment/gateway
kubectl -n starfleet rollout status deployment/edge
kubectl -n starfleet exec deploy/shuttle -- curl -s http://edge.starfleet/headers -H 'traceparent: 00-0af7651916cd43dd8448eb211c80319c-b7ad6b7169203331-01' -H 'tracestate: vendor=starfleet' -H 'baggage: userId=alice'
```

The echo shows `Traceparent` and `Tracestate` and no `Baggage`.

## Step 4: Record the evidence

Save this as `propagation-evidence.yaml`, replacing the time with the current UTC time (`date -u +%Y-%m-%dT%H:%M:%SZ`):

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: propagation-evidence
  namespace: starfleet
data:
  boundary: "gateway removed traceparent and tracestate; edge forwarded baggage from public callers"
  traceparent: "PASS: traceparent reaches the probe through edge and gateway"
  baggage: "PASS: baggage does not reach the probe from the public edge"
  observed-at: "2026-11-03T10:15:00Z"
```

```sh
kubectl apply -f propagation-evidence.yaml
astrona submit --git ssh://git@github.com/astrona-io/ATS076.git -c sections/section-010/capstone/labs/lab-01
```
