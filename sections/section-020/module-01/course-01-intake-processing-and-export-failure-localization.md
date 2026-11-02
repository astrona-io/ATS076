---
draft: true
exam_objectives:
- Debugging Pipelines
---
# Intake, Processing And Export Failure Localization

Missing telemetry can originate anywhere along the evidence path. The application may never record it, the SDK may sample or buffer it, transport may fail, the Collector may filter it, an exporter may reject it or the backend may store it under an unexpected identity. A useful investigation narrows those possibilities by following one signal and its expected contract through each boundary.

Start with production and recording. Identify the instrumentation that should observe the operation and the SDK implementation it uses. Check whether initialization and sampling allow a record to exist. An unsupported library or missing provider can leave nothing for later components to deliver. Reconfiguring a Collector cannot recover an observation that was never produced.

Then examine SDK export. Protocol, endpoint, trust and credentials must agree with the receiver. Batching introduces delay, while a bounded queue can lose data during sustained failure. A process that exits abruptly can discard pending records. These failures can coexist with healthy application behavior, so business success and telemetry delivery should be treated as separate observations.

Collector intake provides the next boundary. Receiver diagnostics and internal metrics can indicate accepted data, but their meaning depends on the component and release. A listening port proves less than observed signal intake. If a receiver accepts traces, the relevant pipeline must still enable compatible processing and export. Defined but unused components are not active evidence paths.

Consider spans arriving at an OTLP receiver while the configured filter removes all spans with a particular service identity. The exporter can be healthy but receive none of those spans. The right repair depends on whether the filter's population is intended. Increasing exporter retries would not change the filtering decision. Following the data path exposes that distinction.

Processing evidence includes transformations, filters and capacity limits. A rule can rename attributes expected by the backend query or remove data entirely. A processor error can affect accepted data according to its error contract. Memory pressure can also cause refusal or loss. Diagnosis should identify the changed population rather than report only that the Collector process remains running.

Export and backend ingestion form another boundary. The exporter may attempt delivery while the backend rejects authentication, protocol or payload semantics. Retries can postpone failure visibility and can create duplicates after ambiguous acknowledgements. A successful send does not necessarily prove the exact analysis query will find the record; resource identity, timestamp range and schema expectations still matter.

Diagnostic exporters can display telemetry at a selected point. They are useful for understanding the current payload, but they can also reveal tokens, identifiers or confidential log bodies. Output needs controlled access and retention. Leaving verbose diagnostic export enabled broadly can increase cost and create an unintended disclosure path. Diagnostic data should not be treated as harmless merely because it appears in operational logs.

Finally, check the consumer query. Wrong time windows, service identity or field names can hide data that was delivered successfully. A schema migration can produce that result after an instrumentation update. The evidence should distinguish absent storage from a query that selects the wrong population.

A clear report states which stages were observed and which remain uncertain. It can identify that spans reach the receiver but fail destination authentication without claiming complete application coverage. This measured conclusion helps students locate and explain failures rather than replace the entire pipeline whenever a dashboard is empty.

## Common pitfalls

> [!WARNING]
> A healthy process or listener does not prove end-to-end telemetry delivery. Follow production, recording, processing and export separately. Diagnostic exporters can disclose sensitive payloads, and an empty query can reflect identity or schema mismatch rather than missing storage.
