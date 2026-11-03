# Question

Solve this question on: `terminal`

Requests from the `shuttle` pod reach the `probe` service through a proxy named `gateway` in the `starfleet` namespace. The `probe` service answers `GET /headers` with the request headers it received. Services behind the gateway still read the B3 and Jaeger formats, and tracing shows that their traces start again at the gateway. The W3C `traceparent` header already arrives.

1. Send requests through `http://gateway.starfleet/headers` with a `b3` header, with the three headers `x-b3-traceid`, `x-b3-spanid` and `x-b3-sampled`, and with an `uber-trace-id` header. Read which of them the `probe` received.
2. Change the gateway configuration so that all of these headers reach the `probe` unchanged.
3. The gateway also removes the header `x-internal-debug` on purpose. This rule is not part of the fault. Keep it.
4. Keep the gateway proxying to the `probe`. Do not delete it, change its image or send traffic around it.

`kubectl` already points at the cluster. The nginx configuration is in the ConfigMap `gateway-conf` in `starfleet`. nginx reads its configuration at start, so the pods must restart after a change.
