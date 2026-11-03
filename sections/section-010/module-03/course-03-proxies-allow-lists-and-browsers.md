---
draft: true
exam_objectives:
  - Context Propagation
---
# Proxies, Allow-lists And Browsers

A service can set up its propagators correctly and still lose the trace, because a component in the middle of the path does not forward the headers. This part describes the three ways a component in the middle treats headers, the list of header names that an allow-list must contain for each format, and the browser rule that blocks trace headers from a web page.

## Three ways a proxy treats headers

A reverse proxy or gateway sits between two services. It receives a request, then sends a new request to the next hop. What it does with the headers of the first request depends on its configuration.

- **Forward all by default.** nginx behaves this way. Every request header reaches the next hop unless a rule changes it. A rule that sets a header to an empty string removes it, because nginx does not send a header with an empty value.
- **Allow-list.** Some gateways, web application firewalls and API management products forward only the headers on a list. A header that is not on the list is removed without a message.
- **Rewrite.** A component can add, replace or remove headers for security, for example to remove a header that a client must not set.

A proxy that forwards all headers by default breaks propagation only when someone writes a rule that removes a header. An allow-list breaks propagation whenever a new format is introduced and nobody adds its headers to the list.

## What an allow-list must contain

For each format a service uses, the allow-list needs every header name of that format. Header names are not case sensitive, so the case does not matter.

| Format | Header names to allow |
| --- | --- |
| `tracecontext` | `traceparent`, `tracestate` |
| `baggage` | `baggage` |
| `b3` | `b3` |
| `b3multi` | `x-b3-traceid`, `x-b3-spanid`, `x-b3-sampled`, `x-b3-parentspanid`, `x-b3-flags` |
| `jaeger` | `uber-trace-id` |

The baggage header is a special case. Allowing it on a public edge lets any caller set baggage, which the earlier module showed to be a trust problem. An allow-list for a public edge lists the trace context headers and leaves `baggage` out.

## Remove only what you mean to remove

A proxy configuration often has a rule that removes a header for a good reason. For example, a rule that removes `X-Internal-Debug` stops callers from switching on debug output. When you repair a propagation fault, remove only the rule that hides the trace headers. A broad clean-up that removes the security rule too creates a new fault.

The check after a repair has two sides. The trace headers must reach the next hop, and the header that the security rule protects must still not reach it. The lab of this module grades both.

## The browser rule for cross-origin requests

A web page that calls an API on another origin sends a cross-origin request. Before the real request, the browser may send a preflight request with the method `OPTIONS`. The preflight asks which request headers the server accepts. The server answers in the header `Access-Control-Allow-Headers`.

The browser tracing library adds `traceparent` to the real request. A header that is not a CORS-safelisted header makes the browser send a preflight. If the answer to the preflight does not list `traceparent`, the browser blocks the real request and the page shows a network error. The list must contain every trace header the page sends:

```
Access-Control-Allow-Headers: traceparent, tracestate, baggage
```

The server cannot repair this from the application tracing code. The change belongs to the API, its proxy or its CORS configuration. The cross-origin rule also hides a quieter fault: if the browser library injects headers only for URLs that match a list in its own configuration, a call to a URL that is not on the list carries no context.

## Run an allow-list check in the playground

In the playground, the `gateway` removes several header names with `proxy_set_header` rules. Look at the configuration:

<!-- astrona:playground:renew -->

```sh
kubectl -n starfleet get configmap gateway-conf -o jsonpath='{.data.nginx\.conf}'
```

Each `proxy_set_header` line that sets a name to an empty string removes that header. Write down the names. Then send one request with a header of each format and compare the echo with the list.

```sh
kubectl -n starfleet exec deploy/shuttle -- curl -s http://gateway.starfleet/headers -H 'x-b3-traceid: 80f198ee56343ba864fe8b2a57d3eff7' -H 'x-b3-spanid: e457b5a2e4d86bd1' -H 'x-b3-sampled: 1'
```

The echo contains none of the three `X-B3-` headers, which matches the removal lines. Notice that the removal of one B3 header and not another would also cut the trace: a receiver that finds `X-B3-TraceId` without `X-B3-SpanId` cannot build a valid span context and ignores the headers.

## Checkpoints

- Which header names does an allow-list need for `b3multi`?
- A browser page sends `traceparent` to an API on another origin and the call fails. Which response header lists the accepted request headers?
- Why should a repair remove only the rule that hides the trace headers?

Answers: `x-b3-traceid`, `x-b3-spanid`, `x-b3-sampled`, `x-b3-parentspanid` and `x-b3-flags`. `Access-Control-Allow-Headers`, in the answer to the preflight request. Another rule may protect the system, and removing it creates a new fault.

You now know how a component in the path can break a format and how to list the headers it must keep. The next part turns this into a repeatable test that names the exact header and hop.

## Common pitfalls

> [!WARNING]
> - Do not put `baggage` on the allow-list of a public edge without a reason.
> - Do not forget that `b3multi` is several headers. Allowing only some of them still breaks it.
> - Do not test a browser call with `curl` only. The preflight is what fails, and `curl` does not send one.
