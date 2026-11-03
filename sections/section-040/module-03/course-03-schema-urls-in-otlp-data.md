---
draft: true
exam_objectives:
  - Schema Management
---
# Schema URLs In OTLP Data

A tool that translates names needs to know which version the data uses now. That information travels with the data as a schema URL. This part shows where the URL appears in OTLP messages, who sets it, and why you cannot treat it as proof that the names are correct.

## Two places for a schema URL

OTLP data is grouped in two levels, and each level has a `schema_url` field.

- The **resource** level. A resource describes the entity that produces the data, for example a service or a host. The URL on the resource tells the version of the conventions used for the resource attributes, such as `service.name` and `host.name`. In the JSON form of OTLP, the field `schemaUrl` appears in the object `resourceSpans`, next to `resource`.
- The **instrumentation scope** level. A scope identifies the library that produced the spans, metrics or logs. The URL on the scope tells the version of the conventions used for the attributes that this library sets, such as `http.request.method`. In OTLP JSON, the field `schemaUrl` appears in the object `scopeSpans`, next to `scope`.

The two URLs can differ. An application can use a new version of an instrumentation library, which follows a new version of the conventions, while its resource attributes come from a resource detector that follows an older version.

## Who sets the URL

The SDK sets the resource URL when it builds the resource. A resource detector can set it to the version of the conventions that the detector follows. The SDK sets the scope URL from the `schema_url` argument that the instrumentation library passes when it gets a tracer, meter or logger. If the library does not pass a value, the field is empty.

A field that is empty means "unknown". It does not mean "the newest version". A consumer must not assume a version for data with no schema URL.

## Merging resources with different URLs

An SDK can merge two resources, for example the resource from the environment and the resource from a detector. If both have a schema URL and the URLs differ, the result cannot name a single version. The specification leaves the result implementation-defined for this case, so SDKs differ. The result is that the final URL is empty, or that the merge reports an error. Check what your SDK does before you rely on a resource URL.

## The URL is metadata

The schema URL records what the producer claims. Nothing in OTLP or in the Collector checks that the names in the data match the version in the URL. A service can send the URL of version 1.21.0 with attribute names from a newer version.

For this reason, the URL helps you in two ways. It tells a tool which translation to attempt. It gives you a lead when you look for old names in a fleet: group the data by schema URL and find the producers that still claim an old version. It does not prove that the names are right. Reading real spans is still the only test.

## Look at the URL in a real request

In the playground, send an OTLP/HTTP request that carries a resource-level and a scope-level schema URL to the Collector, and read it in the log of the Collector.

<!-- astrona:playground:renew -->

```sh
kubectl -n starfleet exec deploy/shuttle -- curl -s -o /dev/null -w '%{http_code}\n' -X POST -H 'Content-Type: application/json' -d '{"resourceSpans":[{"schemaUrl":"https://schemas.example.com/starfleet/1.0.0","resource":{"attributes":[{"key":"service.name","value":{"stringValue":"scout"}}]},"scopeSpans":[{"schemaUrl":"https://schemas.example.com/starfleet/1.1.0","scope":{"name":"lab"},"spans":[{"traceId":"5b8efff798038103d269b633813fc60c","spanId":"eee19b7ec3c1b174","name":"schema-demo","kind":2,"startTimeUnixNano":"1700000000000000000","endTimeUnixNano":"1700000001000000000","attributes":[{"key":"ship.name","value":{"stringValue":"shuttle-1"}}]}]}]}]}' http://otelcol.observability:4318/v1/traces
```

```sh
kubectl -n observability logs deploy/otelcol --tail=60
```

The `debug` exporter with `detailed` verbosity prints a line for the schema URL of the resource and a line for the schema URL of the scope. The two lines hold different versions, which shows that the levels are independent. The attribute `ship.name` is still the legacy name, because the Collector in the playground has no component that applies the schema.

## Checkpoints

- On which two levels does OTLP data carry a schema URL?
- A scope has an empty schema URL. What does a consumer know about its attribute names?
- Does the Collector check that attribute names match the schema URL?

Answers: the resource and the instrumentation scope. Nothing; the version is unknown. No.

You now know where the version travels and why it is only a claim. The last part gives you a method to check a schema file by hand.

## Common pitfalls

> [!WARNING]
> - Do not treat an empty schema URL as the newest version.
> - Do not trust a schema URL as proof of correct names.
> - Do not read only the resource URL. The scope URL can name another version.
