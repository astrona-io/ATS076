#!/usr/bin/env bash
# The schema file names its own URL and its file format
set -uo pipefail

schema_text() { kubectl -n starfleet get configmap schema-file -o jsonpath='{.data.schema\.yaml}' 2>/dev/null; }
fail=0
fail_with() { echo "FAIL: $1"; fail=1; }

txt="$(schema_text)"
if [ -z "$txt" ]; then fail_with "the ConfigMap schema-file has no key schema.yaml"; fi
if ! echo "$txt" | grep -q '^file_format: 1\.1\.0$'; then fail_with "file_format must be 1.1.0 at the top level"; fi
if ! echo "$txt" | grep -q '^schema_url: https://schemas\.example\.com/starfleet/1\.2\.0$'; then fail_with "schema_url must be https://schemas.example.com/starfleet/1.2.0 at the top level"; fi

if [ "$fail" -eq 0 ]; then echo "PASS: The schema file names its own URL and its file format"; fi
exit "$fail"
