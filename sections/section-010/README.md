---
draft: true
exam_objectives:
  - Context Propagation
---
# Section 010: Context Propagation

This section teaches you to find where a trace is cut in two and to decide which context may cross a trust boundary: the traceparent and tracestate headers, a hop-by-hop test that finds the proxy that removes them, baggage, and removal of untrusted baggage at a public edge.

**Exam objective covered:** Context Propagation

---

## What You Will Master

- Describe the fields of `traceparent` and `tracestate` and what a receiver does with them.
- Explain how a lost header changes sampling and splits a trace.
- Find the hop that removes a header by asking each hop what it received.
- Explain baggage and why headers from outside a trust boundary are untrusted.
- Remove baggage from public callers only and prove the result.

---

## The Learning Path

### 1. Trace Context Across Process Boundaries
*   **Module Reader:** **[Module 1: Trace Context Across Process Boundaries](./module-01/course.md)**
*   **Hands-on Playground:** `sections/section-010/module-01/playground` - kind cluster, `kubectl`. A `shuttle` pod, a `probe` that echoes request headers and a `gateway` proxy that removes `traceparent` and `tracestate`.
    ```bash
    astrona run --git ssh://git@github.com/astrona-io/ATS076.git -c sections/section-010/module-01/playground
    ```
*   **Lab:** `sections/section-010/module-01/labs/lab-01` (UNTESTED)
    ```bash
    astrona run --git ssh://git@github.com/astrona-io/ATS076.git -c sections/section-010/module-01/labs/lab-01
    astrona submit -c .
    ```

### 2. Baggage And Trust Boundaries
*   **Module Reader:** **[Module 2: Baggage And Trust Boundaries](./module-02/course.md)**
*   **Hands-on Playground:** `sections/section-010/module-02/playground` - kind cluster, `kubectl`. A `shuttle` pod, a `probe` and an `edge` proxy with a public listener and an internal listener.
    ```bash
    astrona run --git ssh://git@github.com/astrona-io/ATS076.git -c sections/section-010/module-02/playground
    ```
*   **Lab:** `sections/section-010/module-02/labs/lab-01` (UNTESTED)
    ```bash
    astrona run --git ssh://git@github.com/astrona-io/ATS076.git -c sections/section-010/module-02/labs/lab-01
    astrona submit -c .
    ```

### Section Capstone Challenge
*   **Comprehensive Challenge:** Context Propagation Capstone - `sections/section-010/capstone/labs/lab-01` (UNTESTED)
    ```bash
    astrona run --git ssh://git@github.com/astrona-io/ATS076.git -c sections/section-010/capstone/labs/lab-01
    astrona submit -c .
    ```
*   **Hands-on Objective:** Two proxies, `edge` and `gateway`, stand between public callers and the `probe`. Find the proxy that removes the trace context, make the headers reach the `probe`, drop baggage from public callers at the `edge` and record the evidence in the ConfigMap `propagation-evidence`. The grader checks live requests.

### Knowledge Check
*   **Quiz:** 10 questions in `sections/section-010/quiz.yaml`. The pass score is 70 percent.
