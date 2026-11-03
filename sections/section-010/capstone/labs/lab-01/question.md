# Question

Solve this question on: `terminal`

Public callers reach the `probe` service in `starfleet` through two proxies in a chain: the `edge` proxy forwards to the `gateway` proxy, and the `gateway` forwards to the `probe`. The `probe` answers `GET /headers` with the request headers it received. Tracing shows two problems: traces break at the `probe`, and a public caller can send a `baggage` header that reaches internal services.

1. Find which hop removes the W3C Trace Context headers (`traceparent` and `tracestate`) and make both reach the `probe` from a request sent to `http://edge.starfleet/headers`.
2. Make the `edge` proxy drop the `baggage` header from public callers.
3. Do not delete a proxy, change an image or send traffic around a proxy.
4. Record the evidence in a ConfigMap `propagation-evidence` in `starfleet` with these keys:
   - `boundary`: the proxy that removed the trace context (it must name `gateway`).
   - `traceparent` and `baggage`: one line each, starting with `PASS` and saying what you observed.
   - `observed-at`: the time of your last check in UTC, in the form `2026-11-03T10:15:00Z`.

The nginx configurations are in the ConfigMaps `edge-conf` and `gateway-conf`. nginx reads its configuration at start, so restart a proxy after you change it.
