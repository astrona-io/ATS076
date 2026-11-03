# Question

Solve this question on: `terminal`

Requests from the `shuttle` pod reach the `probe` service through a proxy named `gateway` in the `starfleet` namespace. The `probe` service answers `GET /headers` with the request headers it received. Tracing from the `shuttle` side shows that every request to `probe` starts a new trace: the W3C Trace Context headers do not arrive.

1. Find out where the gateway removes the context. Send a request with a `traceparent` header through `http://gateway.starfleet/headers` and read what the `probe` received.
2. Change the gateway configuration so that both `traceparent` and `tracestate` reach the `probe` unchanged.
3. Keep the gateway proxying to the `probe`. Do not delete it, change its image or send traffic around it.

`kubectl` already points at the cluster. The nginx configuration is in the ConfigMap `gateway-conf` in `starfleet`. nginx reads its configuration at start, so the pods must restart after a change.
