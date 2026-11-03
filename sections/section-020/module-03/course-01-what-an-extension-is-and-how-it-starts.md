---
draft: true
exam_objectives:
  - Debugging Pipelines
---
# What An Extension Is And How It Starts

A pipeline moves telemetry from receivers through processors to exporters. Many tasks around that flow are not part of it: answering a health probe, offering a debugging page, storing queue data on disk or fetching credentials. The Collector places this work in a fourth kind of component. This part explains what an extension is, where it is configured and the two settings that decide whether it runs and who can reach it.

## Extensions sit beside the pipelines

An extension is a Collector component that adds a capability without handling telemetry data. Receivers, processors and exporters form pipelines. Extensions do not. They have no input from a pipeline and no output to one.

The Collector configuration has a top-level section named `extensions`. In it, each key is a component type, optionally followed by a slash and a name. For example, `health_check` and `zpages` are two extensions, and `otlp/grpc` would be a receiver named `grpc` of the type `otlp`.

```yaml
extensions:
  health_check:
    endpoint: 0.0.0.0:13133
  zpages:
    endpoint: localhost:55679
```

Defining an extension in this section does not start it. The Collector starts only the extensions that are listed in `service.extensions`:

```yaml
service:
  extensions: [health_check, zpages]
```

This is the same rule that applies to receivers and exporters, which must be listed in a pipeline. An extension that is defined and not listed is accepted by the configuration check and never starts. Nothing listens on its port, and no log line says that it was skipped.

## The endpoint setting decides who can connect

Most diagnostic extensions open a network port. The `endpoint` setting has the form `host:port`. The host part decides which network interfaces accept connections.

- `localhost:55679` accepts connections only from inside the same network namespace. In Kubernetes, that is the pod itself. Another pod cannot connect, and a Service in front of the pod cannot forward to it.
- `0.0.0.0:55679` accepts connections on every interface of the pod, so a Service and other pods can connect.

Recent Collector releases bind many extensions to `localhost` by default, to avoid exposing a debugging page by accident. For this reason, a diagnostic extension that works on a laptop can be unreachable in a cluster until you change the host part.

## Two faults that look the same

Both faults produce the same symptom: a connection to the port fails, or the request times out.

1. The extension is not listed in `service.extensions`, so no process listens on the port.
2. The extension runs, but its endpoint is bound to `localhost`, so the connection from outside the pod is refused.

You separate the two with the Collector log and with a request from inside the pod. The Collector log shows the startup of each extension that runs. A request from inside the same pod, with `kubectl exec` and a tool in the Collector image, or with `kubectl port-forward`, succeeds in fault 2 and fails in fault 1.

## Reach a localhost endpoint with port-forward

The command `kubectl port-forward` opens a connection from your machine into the network namespace of the pod. For that reason, it reaches a port that is bound to `localhost` inside the pod.

<!-- astrona:playground:renew -->

In the playground, the Collector listens on its endpoints inside the `observability` namespace. Forward the port and read the page from your machine:

```sh
kubectl -n observability port-forward deploy/otelcol 55679:55679
```

In a second terminal, request a page:

```sh
curl -s -o /dev/null -w '%{http_code}\n' http://localhost:55679/debug/servicez
```

A status of 200 shows that the extension runs. A refused connection while the port-forward is open shows that the extension is not listed or not started. Stop the port-forward with `Ctrl+C` when you are done.

## Checkpoints

- An extension is in the `extensions` section but not in `service.extensions`. Does it start?
- What is the difference between the endpoints `localhost:1777` and `0.0.0.0:1777`?
- Why does `kubectl port-forward` reach a port that is bound to `localhost`?

Answers: no. The first accepts connections only from inside the pod and the second from any interface. The forward connects inside the network namespace of the pod.

You now know the two settings that make an extension run and reachable. The next part uses them with the extension that shows the structure of a running Collector.

## Common pitfalls

> [!WARNING]
> - Do not assume that a defined extension runs. List it in `service.extensions`.
> - Do not publish a debugging extension on `0.0.0.0` in production without a network policy or another control.
> - Do not debug the port first. Check the list in `service.extensions`, then the host part of the endpoint.
