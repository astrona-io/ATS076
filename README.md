# Maintaining and Debugging Observability Pipelines (ATS076)

OpenTelemetry Certified Associate (OTCA): Maintaining and Debugging Observability Pipelines, worth 10% of the official curriculum. This course belongs to ATP015.

Concept lessons, diagrams, playgrounds, graded labs, capstones and original scenario quizzes cover every published objective in this domain. Every section has an introduction, a capstone lab and a quiz, and every module has a playground, a graded lab and a closing summary. Labs run on kind (Kubernetes 1.35) with the OpenTelemetry Collector and were built without being run: each lab README says UNTESTED. Technical content remains draft.

## Course Outline

| Section / module | Module | Teaching files |
| --- | --- | --- |
| 010 / 01 | Trace Context Across Process Boundaries | The Trace Context Headers; Finding Where The Context Stops |
| 010 / 02 | Baggage And Trust Boundaries | Baggage And How It Travels; Untrusted Context At The Edge |
| 010 / 03 | Propagator Formats And Header Allow-lists | One Span Context, Several Header Formats; Mixed Fleets And Composite Propagators; Proxies, Allow-lists And Browsers; Proving Header Formats With Requests |
| 020 / 01 | Components And Pipelines | How A Collector Builds Pipelines; Checking Intake With Debug, Health And Metrics |
| 020 / 02 | Locating Data Loss Between Stages | Counting Items Between Stages; Processors That Drop Data |
| 020 / 03 | Collector Diagnostic Extensions | What An Extension Is And How It Starts; The zPages Extension; The pprof Extension And The Health Check; Choosing The Right Diagnostic Tool |
| 030 / 01 | Exporter Retry And Queues | What Happens When An Export Fails; Sizing Queues And Persistent Storage |
| 030 / 02 | Protecting The Collector Memory | The Memory Limiter; Refusing Data And Its Effect On Senders |
| 030 / 03 | OTLP Responses And Retry Semantics | What An OTLP Server Answers; Retryable And Permanent Errors; Partial Success And Rejected Items; Throttling, Backoff And Failure Evidence |
| 040 / 01 | Semantic Conventions And Renaming | Semantic Conventions And Attribute Names; Renaming Attributes With OTTL |
| 040 / 02 | Migration Windows | Schema Versions And Compatibility For Consumers; Dual Emission During A Migration |
| 040 / 03 | Schema Files And Transformations | The Layout Of A Schema File; Transformations And Their Direction; Schema URLs In OTLP Data; Checking A Schema File By Hand |

## Author Review

See [curriculum coverage](CURRICULUM.md), [primary sources](SOURCES.md), [question-bank documentation](ASSESSMENTS.md) and [contribution instructions](CONTRIBUTING.md). Labs and playgrounds are static-checked only (`astrona validate`, `bash -n`, YAML parsing); no runtime execution is claimed.
