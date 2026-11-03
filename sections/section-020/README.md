---
draft: true
exam_objectives:
  - Debugging Pipelines
---
# Section 020: Debugging Pipelines

This section teaches you to find the stage of a Collector pipeline that loses telemetry: how components are started, evidence from the debug exporter, the health check and the internal metrics, counters compared between stages, and the processor rules that remove data.

**Exam objective covered:** Debugging Pipelines

---

## What You Will Master

- Explain which Collector components start and why an unlisted component is silent.
- Use the debug exporter, the health check and the internal metrics as evidence.
- Compare counters between stages to locate the stage that loses items.
- Read a filter condition and correct an inverted rule.
- Record the cause of each fault found.

---

## The Learning Path

### 1. Components And Pipelines
*   **Module Reader:** **[Module 1: Components And Pipelines](./module-01/course.md)**
*   **Hands-on Playground:** `sections/section-020/module-01/playground` - kind cluster, `kubectl`. A Collector with an OTLP/gRPC and an OTLP/HTTP receiver, where only the gRPC receiver is in the traces pipeline.
    ```bash
    astrona run --git ssh://git@github.com/astrona-io/ATS076.git -c sections/section-020/module-01/playground
    ```
*   **Lab:** `sections/section-020/module-01/labs/lab-01` (UNTESTED)
    ```bash
    astrona run --git ssh://git@github.com/astrona-io/ATS076.git -c sections/section-020/module-01/labs/lab-01
    astrona submit -c .
    ```

### 2. Locating Data Loss Between Stages
*   **Module Reader:** **[Module 2: Locating Data Loss Between Stages](./module-02/course.md)**
*   **Hands-on Playground:** `sections/section-020/module-02/playground` - kind cluster, `kubectl`. A Collector with a `filter/health` processor whose condition drops every span except the health check.
    ```bash
    astrona run --git ssh://git@github.com/astrona-io/ATS076.git -c sections/section-020/module-02/playground
    ```
*   **Lab:** `sections/section-020/module-02/labs/lab-01` (UNTESTED)
    ```bash
    astrona run --git ssh://git@github.com/astrona-io/ATS076.git -c sections/section-020/module-02/labs/lab-01
    astrona submit -c .
    ```

### Section Capstone Challenge
*   **Comprehensive Challenge:** Debugging Pipelines Capstone - `sections/section-020/capstone/labs/lab-01` (UNTESTED)
    ```bash
    astrona run --git ssh://git@github.com/astrona-io/ATS076.git -c sections/section-020/capstone/labs/lab-01
    astrona submit -c .
    ```
*   **Hands-on Objective:** Fix the receiver that is not in the pipeline, the filter condition and the unlisted health check extension, then record the cause of each fault in the ConfigMap `pipeline-evidence`. The grader sends spans and reads the Collector output.

### Knowledge Check
*   **Quiz:** 10 questions in `sections/section-020/quiz.yaml`. The pass score is 70 percent.
