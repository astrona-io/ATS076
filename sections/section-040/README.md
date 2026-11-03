---
draft: true
exam_objectives:
  - Schema Management
---
# Section 040: Schema Management

This section teaches you to keep telemetry usable while attribute names change: semantic conventions, legacy and stable names, safe renames with the transform processor, schema versions, consumer impact and a dual emission window.

**Exam objective covered:** Schema Management

---

## What You Will Master

- Explain what semantic conventions define and why names change.
- Rename attributes with the transform processor and guard the copy.
- Explain what a schema URL does and does not prove.
- List the consumers that depend on a name.
- Build and prove a dual emission window.

---

## The Learning Path

### 1. Semantic Conventions And Renaming
*   **Module Reader:** **[Module 1: Semantic Conventions And Renaming](./module-01/course.md)**
*   **Hands-on Playground:** `sections/section-040/module-01/playground` - kind cluster, `kubectl`. A Collector with no processor and spans that use legacy HTTP attribute names.
    ```bash
    astrona run --git ssh://git@github.com/astrona-io/ATS076.git -c sections/section-040/module-01/playground
    ```
*   **Lab:** `sections/section-040/module-01/labs/lab-01` (UNTESTED)
    ```bash
    astrona run --git ssh://git@github.com/astrona-io/ATS076.git -c sections/section-040/module-01/labs/lab-01
    astrona submit -c .
    ```

### 2. Migration Windows
*   **Module Reader:** **[Module 2: Migration Windows](./module-02/course.md)**
*   **Hands-on Playground:** `sections/section-040/module-02/playground` - kind cluster, `kubectl`. A Collector that renames legacy HTTP attributes and deletes the old names.
    ```bash
    astrona run --git ssh://git@github.com/astrona-io/ATS076.git -c sections/section-040/module-02/playground
    ```
*   **Lab:** `sections/section-040/module-02/labs/lab-01` (UNTESTED)
    ```bash
    astrona run --git ssh://git@github.com/astrona-io/ATS076.git -c sections/section-040/module-02/labs/lab-01
    astrona submit -c .
    ```

### Section Capstone Challenge
*   **Comprehensive Challenge:** Schema Management Capstone - `sections/section-040/capstone/labs/lab-01` (UNTESTED)
    ```bash
    astrona run --git ssh://git@github.com/astrona-io/ATS076.git -c sections/section-040/capstone/labs/lab-01
    astrona submit -c .
    ```
*   **Hands-on Objective:** Rename two legacy HTTP attributes, keep `net.peer.name` and `server.address` together for a window, and record the evidence in the ConfigMap `schema-evidence`. The grader sends legacy and stable spans and reads the output.

### Knowledge Check
*   **Quiz:** 10 questions in `sections/section-040/quiz.yaml`. The pass score is 70 percent.
