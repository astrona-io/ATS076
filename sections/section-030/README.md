---
draft: true
exam_objectives:
  - Error Handling
---
# Section 030: Error Handling

This section teaches you to keep telemetry through an outage and a spike: the path of a failed batch, retry and queue settings, queue sizing, persistent storage, the memory limiter and what a refusal means for the senders.

**Exam objective covered:** Error Handling

---

## What You Will Master

- Follow a failed batch through the queue, the retry wait and the drop.
- Configure `retry_on_failure` and `sending_queue` and size a queue from a rate and an outage.
- Keep a queue across a restart with `file_storage`.
- Set and place the `memory_limiter` for a container limit.
- Explain what a refusal means for senders.

---

## The Learning Path

### 1. Exporter Retry And Queues
*   **Module Reader:** **[Module 1: Exporter Retry And Queues](./module-01/course.md)**
*   **Hands-on Playground:** `sections/section-030/module-01/playground` - kind cluster, `kubectl`. A Collector that exports to a `backend`, with `retry_on_failure` and `sending_queue` switched off.
    ```bash
    astrona run --git ssh://git@github.com/astrona-io/ATS076.git -c sections/section-030/module-01/playground
    ```
*   **Lab:** `sections/section-030/module-01/labs/lab-01` (UNTESTED)
    ```bash
    astrona run --git ssh://git@github.com/astrona-io/ATS076.git -c sections/section-030/module-01/labs/lab-01
    astrona submit -c .
    ```

### 2. Protecting The Collector Memory
*   **Module Reader:** **[Module 2: Protecting The Collector Memory](./module-02/course.md)**
*   **Hands-on Playground:** `sections/section-030/module-02/playground` - kind cluster, `kubectl`. A Collector with a `memory_limiter` that is last in the pipeline and has a limit above its 256Mi container.
    ```bash
    astrona run --git ssh://git@github.com/astrona-io/ATS076.git -c sections/section-030/module-02/playground
    ```
*   **Lab:** `sections/section-030/module-02/labs/lab-01` (UNTESTED)
    ```bash
    astrona run --git ssh://git@github.com/astrona-io/ATS076.git -c sections/section-030/module-02/labs/lab-01
    astrona submit -c .
    ```

### Section Capstone Challenge
*   **Comprehensive Challenge:** Error Handling Capstone - `sections/section-030/capstone/labs/lab-01` (UNTESTED)
    ```bash
    astrona run --git ssh://git@github.com/astrona-io/ATS076.git -c sections/section-030/capstone/labs/lab-01
    astrona submit -c .
    ```
*   **Hands-on Objective:** Order and size the `memory_limiter`, switch on retry and a queue with persistent storage for `otlp_http/backend`, and record the configuration in the ConfigMap `loss-evidence`. The grader stops the `backend` for a short time and checks that a span arrives later.

### Knowledge Check
*   **Quiz:** 10 questions in `sections/section-030/quiz.yaml`. The pass score is 70 percent.
