---
draft: true
exam_objectives:
- Context Propagation
---
# Broken Trace Relationships And Propagation Diagnosis

A broken trace graph can result from several different failures. The sender may not inject context, an intermediary may remove the carrier fields, the receiver may not extract them, or local asynchronous work may lose the active context. Sampling and missing instrumentation can also remove spans without breaking propagation itself. Diagnosis should follow these boundaries rather than assume that every gap is an exporter problem.

Begin with the operation whose relationship is missing. Identify the sender and receiver, the communication protocol and the propagator each side expects. HTTP headers, message properties and custom carriers have different supported contracts. A sender that writes context into one location and a receiver that reads another can produce successful business communication with disconnected tracing.

Intermediaries matter. A reverse proxy, API gateway or message adapter can filter metadata. Security policy may intentionally remove untrusted headers at an entry boundary, while an accidental mapping can drop required fields internally. The repair depends on the intended trust design. Blindly forwarding every header can restore a relationship while creating a new confidentiality or spoofing problem.

Consider an order service calling inventory. If inventory starts every request as an independent root, inspect whether the order client injects supported context and whether inventory extracts it before starting its server span. If both sides have correct code but a gateway removes the relevant fields, the failing boundary lies between them. Renaming the spans cannot repair that missing relationship.

Within a process, asynchronous execution can change context scope. A task scheduled after the request handler returns may not inherit the intended active context automatically. A reused callback can also execute under a different request. The language's context mechanism and instrumentation support determine how work should preserve or explicitly associate context. Parent identifiers should represent the actual causal relationship rather than a guess based on timestamps.

Messaging can require richer reasoning. A consumer batch can be influenced by several producer operations. Links may express those relationships more faithfully than forcing one arbitrary parent. A delayed message can also outlive its original request. The intended instrumentation semantics should explain whether the consumer creates a child, a new root with links or another supported structure.

Sampling is separate evidence. A valid propagated context can refer to a request whose detailed spans are not retained. A downstream library can also be uninstrumented while context continues through the request. The analysis backend may then display gaps even though the transport preserved identifiers. Diagnosis should distinguish missing relationships from missing recorded operations.

Malformed or inconsistent context deserves controlled handling. Implementations should follow supported parsing behavior rather than accept arbitrary invented formats. Context received from an external caller is untrusted. A trace identifier is useful for joining evidence, but it does not establish an authenticated user or permission to read another tenant's data. Baggage needs its own allowed-value and disclosure policy.

Useful evidence includes the expected propagation contract, sender behavior, intermediary handling and receiver scope. Logs with correlation information can help when they avoid secrets and accurately identify the active context. A diagnostic report should state what was observed at each boundary instead of claiming that a visually plausible graph proves complete request coverage.

## Common pitfalls

> [!WARNING]
> Successful requests can still lose context. Separate propagation, recording and sampling, including asynchronous and messaging semantics. Do not fabricate parent relationships or trust incoming trace identifiers as authorization.
