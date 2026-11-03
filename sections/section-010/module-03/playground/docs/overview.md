# Header Formats Through A Gateway

This playground starts a kind cluster (Kubernetes 1.35) and applies the example workloads. It was built without being booted.

## What is running

A `shuttle` pod, a `probe` that echoes request headers, and a `gateway` nginx proxy. The gateway removes the headers `b3`, `x-b3-traceid`, `x-b3-spanid`, `x-b3-sampled`, `uber-trace-id` and `x-internal-debug`. It forwards `traceparent` and `tracestate`.

The `shuttle` pod in `starfleet` has `curl`. The nginx configuration is the key `nginx.conf` of the ConfigMap `gateway-conf` in `starfleet`. nginx reads its configuration at start, so restart the Deployment after an edit.

## Things to try

- Send a request with a `b3` header straight to `probe`, then through `gateway.starfleet`, and compare the echoes.
- Send only `x-b3-traceid` and `x-b3-spanid` without `x-b3-sampled` and see which headers arrive.
- Remove the rule for `uber-trace-id`, restart the gateway and repeat the request.
- Add a `proxy_set_header` line that sets `traceparent` to a fixed value and watch what the probe receives.

Nothing here is graded.
