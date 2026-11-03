---
estimated_duration: 20m
---

# Lab: Repair A Schema File

Graded lab. **Status: UNTESTED.** It was built without booting the lab; run `astrona test -c .` before relying on it. Open risks: the exact output text of Collector components and the component names of the pinned Collector release (`otel/opentelemetry-collector-contrib:0.164.0`).

A schema file in a ConfigMap has several mistakes that a tolerant reader would skip without an error. The task is in `question.md`; the walkthrough is in `solution.md`.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS076.git -c sections/section-040/module-03/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS076.git -c sections/section-040/module-03/labs/lab-01
astrona destroy ats-076-lab-040-03
```

## Checks

| Script | What it proves |
| --- | --- |
| `validate-schema-header.sh` | The schema file names its own URL and its file format |
| `validate-transformation-keys.sh` | Every transformation key is spelled as the format defines it |
| `validate-maps-and-versions.sh` | Every attribute_map is a map of old to new and all versions are listed |
