# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check. This lab was built without running it, so the text describes what you should see instead of printing output.

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS076.git -c sections/section-010/module-02/labs/lab-01
```

`astrona submit` right after the start shows two passing checks: `public-traceparent-kept` and `internal-baggage-kept`. They stay your guards.

## Step 1: Observe both listeners

```sh
kubectl -n starfleet exec deploy/shuttle -- curl -s http://edge.starfleet/headers -H 'traceparent: 00-0af7651916cd43dd8448eb211c80319c-b7ad6b7169203331-01' -H 'baggage: userId=alice'
kubectl -n starfleet exec deploy/shuttle -- curl -s http://edge.starfleet:8081/headers -H 'traceparent: 00-0af7651916cd43dd8448eb211c80319c-b7ad6b7169203331-01' -H 'baggage: userId=alice'
```

Both echoes contain `Baggage` with `userId=alice`. The public listener passes caller-controlled data into the organization.

## Step 2: Remove baggage on the public listener only

```sh
kubectl -n starfleet edit configmap edge-conf
```

In the `server` block with `listen 80;`, add this line below the `Host` line:

```
proxy_set_header baggage "";
```

nginx does not send a header whose value is empty, so the header is removed. Do not edit the block with `listen 8081;`. Restart the edge:

```sh
kubectl -n starfleet rollout restart deployment/edge
kubectl -n starfleet rollout status deployment/edge
```

Repeat the two requests from step 1. The public echo has `Traceparent` and no `Baggage`. The internal echo still has both.

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS076.git -c sections/section-010/module-02/labs/lab-01 --keep
```

All three checks pass.
