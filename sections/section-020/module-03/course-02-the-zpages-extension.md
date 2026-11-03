---
draft: true
exam_objectives:
  - Debugging Pipelines
---
# The zPages Extension

Reading a configuration file shows what you asked the Collector to build. It does not show what the Collector built. The `zpages` extension serves a set of web pages from inside the running process. Each page shows one part of the live state: the service, the pipelines, the extensions and the Collector's own spans. This part explains what each page shows and how to use them to check a pipeline against its configuration.

## What zPages is

zPages is a set of HTML pages that the `zpages` extension serves on one HTTP port. The pages are meant for people, not for monitoring systems. They show the state of the process at the time of the request and need no database or other service.

The default endpoint is `localhost:55679`. You set it with the `endpoint` field:

```yaml
extensions:
  zpages:
    endpoint: 0.0.0.0:55679
service:
  extensions: [zpages]
```

## The pages

All pages are under the path `/debug/`.

| Path | What it shows |
| --- | --- |
| `/debug/servicez` | The service: the build version of the Collector and the components compiled into it. |
| `/debug/pipelinez` | The pipelines that are running, with the receivers, processors and exporters of each. |
| `/debug/extensionz` | The extensions that are running. |
| `/debug/featurez` | The feature gates and their current state. |
| `/debug/tracez` | The Collector's own spans, grouped by span name and by latency. |

The pages that matter most when you check a configuration are `pipelinez` and `extensionz`. They list what is running. A component that you defined but did not list in a pipeline is absent from `pipelinez`. An extension that you defined but did not list in `service.extensions` is absent from `extensionz`.

## Use pipelinez to compare the configuration with the process

The method has three steps. Write down the pipelines that you expect from the configuration. Open `pipelinez` and write down the pipelines that run. Compare the two lists.

<!-- astrona:playground:renew -->

Forward the port from your machine to the Collector pod. Run this in one terminal and leave it open:

```sh
kubectl -n observability port-forward deploy/otelcol 55679:55679
```

Then request the page in a second terminal:

```sh
curl -s http://localhost:55679/debug/pipelinez
```

The answer is an HTML page. It lists each pipeline with its type, whether it mutates data and its receivers, processors and exporters. If a receiver is missing from the list of a pipeline, the receiver is not in the `receivers` list of that pipeline in the configuration, however well it is defined at the top.

Now request the extensions page:

```sh
curl -s http://localhost:55679/debug/extensionz
```

The page lists the running extensions. `zpages` itself is in the list, because you are reading its page. When `health_check` is missing, you know that it is not in `service.extensions`.

## The tracez page and the Collector's own spans

The `tracez` page shows spans that the Collector creates about its own work, for example for a batch that an exporter sends. The spans appear in count columns for running spans and in latency buckets for finished spans. A bucket with many spans of high latency points at a slow component.

The page tells you where the Collector spends time. It does not show the telemetry that flows through the Collector. To see that data, use the `debug` exporter.

## Limits of zPages

The pages show the state at the moment of the request. They keep no history, so they cannot tell you what happened five minutes ago. For history, use the internal metrics and the log. The pages are also not an interface for automation. The HTML can change between releases, so do not write scripts that parse it.

## Checkpoints

- Which page lists the receivers, processors and exporters of each running pipeline?
- A receiver is defined and listed in no pipeline. Does it appear on `pipelinez`?
- Which tool shows the telemetry that flows through the Collector, zPages or the `debug` exporter?

Answers: `/debug/pipelinez`. No. The `debug` exporter.

You now know how to read the structure of the running Collector and compare it with the file. The next part covers the extension that shows where CPU and memory go, and the health check that Kubernetes asks.

## Common pitfalls

> [!WARNING]
> - Do not read `tracez` as a view of your application traces. It shows the Collector's own spans.
> - Do not parse the HTML of zPages in scripts.
> - Do not open the zPages port to a public network. It exposes internal details of the process.
