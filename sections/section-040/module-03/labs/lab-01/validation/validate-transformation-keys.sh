#!/usr/bin/env bash
# Every transformation key is spelled as the format defines it
set -uo pipefail

schema_text() { kubectl -n starfleet get configmap schema-file -o jsonpath='{.data.schema\.yaml}' 2>/dev/null; }
fail=0
fail_with() { echo "FAIL: $1"; fail=1; }

txt="$(schema_text)"
if echo "$txt" | grep -q 'rename_attribute:'; then fail_with "the key rename_attribute is misspelled; the key is rename_attributes"; fi
n="$(echo "$txt" | grep -c 'rename_attributes:')"
if [ "$n" -ne 2 ]; then fail_with "found $n rename_attributes entries, expected 2 (one in spans, one in resources)"; fi

if [ "$fail" -eq 0 ]; then echo "PASS: Every transformation key is spelled as the format defines it"; fi
exit "$fail"
