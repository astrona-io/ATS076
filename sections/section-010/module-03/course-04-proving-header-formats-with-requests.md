---
draft: true
exam_objectives:
  - Context Propagation
---
# Proving Header Formats With Requests

Reading a proxy configuration tells you what the proxy should do. A request tells you what it does. This part turns the earlier ideas into one repeatable test: send one request that carries a header of every format and every header that must stay hidden, then compare the echo from a hop with the echo from the hop behind it.

## Build one test request

A good test request carries three groups of headers.

- The trace headers of every format the fleet uses, with a fixed trace identifier that you can find in the echo.
- A marker header that the proxy must not forward, for example `X-Internal-Debug`, to prove that a security rule still works.
- A header that every proxy forwards, for example `X-Request-Check`, to prove that the echo shows what the hop received.

```sh
kubectl -n starfleet exec deploy/shuttle -- curl -s http://gateway.starfleet/headers \
  -H 'traceparent: 00-80f198ee56343ba864fe8b2a57d3eff7-e457b5a2e4d86bd1-01' \
  -H 'tracestate: vendor=starfleet' \
  -H 'b3: 80f198ee56343ba864fe8b2a57d3eff7-e457b5a2e4d86bd1-1' \
  -H 'x-b3-traceid: 80f198ee56343ba864fe8b2a57d3eff7' \
  -H 'x-b3-spanid: e457b5a2e4d86bd1' \
  -H 'x-b3-sampled: 1' \
  -H 'uber-trace-id: 80f198ee56343ba864fe8b2a57d3eff7:e457b5a2e4d86bd1:0:1' \
  -H 'x-internal-debug: on' \
  -H 'x-request-check: present'
```

<!-- astrona:playground:renew -->

Run the same request against the `probe` directly and against the `gateway`. The echo from the `probe` is the reference. The echo from the `gateway` shows what the gateway forwards.

## Read the difference

Make a table of the two echoes. For each header name, write whether it is present in the reference and in the gateway echo.

| Header | Reference (`probe`) | Through the `gateway` | Meaning |
| --- | --- | --- | --- |
| `Traceparent` | present | present | Forwarded. |
| `B3` | present | missing | The gateway removes the single B3 header. |
| `X-B3-Traceid` | present | missing | The gateway removes the multi-header form. |
| `Uber-Trace-Id` | present | missing | The gateway removes the Jaeger header. |
| `X-Internal-Debug` | present | missing | Intended. A security rule removes it. |
| `X-Request-Check` | present | present | The echo is trustworthy. |

The last line matters. If `X-Request-Check` were missing, the echo itself would be unreliable, and you could not draw conclusions from the other lines.

## Repair in the right order

The repair has four steps. First, change the proxy configuration so that only the rules for trace headers are removed. Second, keep the rule that removes `X-Internal-Debug`. Third, restart the proxy, because nginx reads its configuration at start. Fourth, run the test request again and check both sides: the trace headers are now present, and the marker header is still missing.

```sh
kubectl -n starfleet rollout restart deployment/gateway
kubectl -n starfleet rollout status deployment/gateway
```

A test that checks only that headers arrive can pass after a repair that also removed the security rule. A test that checks both sides cannot.

## Keep the test for later

Save the request as a script in the repository of the proxy configuration, and run it after each change of the proxy. A new format, a new proxy version or a new rule may break a header that worked before. The test takes seconds and names the header and the hop.

For a longer chain, run the test against each hop from the last one to the first, as in the first module. The first hop that shows a missing trace header is the hop to repair. When the chain has more than one fault, repeat the process until every trace header reaches the last hop.

## Checkpoints

- Why does the test request include a header that every proxy forwards?
- Why must a repair test also check that `X-Internal-Debug` is still removed?
- After a configuration change, nginx still shows the old behaviour. What did you forget?

Answers: It proves that the echo shows what the hop received. A repair must not remove a security rule that protects the system. To restart the proxy, because nginx reads its configuration at start.

You can now find which header name of which format a hop removes, repair it without touching unrelated rules and prove the result with a request that you can run again.

## Common pitfalls

> [!WARNING]
> - Do not compare an echo with an echo from another request. Use the same request against each hop.
> - Do not delete a rule only because it is on the same hop as the fault.
> - Do not stop after the first fixed header. Check every header name of every format in use.
