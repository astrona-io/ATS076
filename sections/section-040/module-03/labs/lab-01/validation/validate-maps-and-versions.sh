#!/usr/bin/env bash
# Every attribute_map is a map of old to new and all versions are listed
set -uo pipefail

schema_text() { kubectl -n starfleet get configmap schema-file -o jsonpath='{.data.schema\.yaml}' 2>/dev/null; }
fail=0
fail_with() { echo "FAIL: $1"; fail=1; }

txt="$(schema_text)"
for v in 1.2.0 1.1.0 1.0.0; do
  if ! echo "$txt" | grep -q "^  $v:"; then fail_with "version $v is not listed under versions"; fi
done
if ! echo "$txt" | grep -q '^ *ship\.name: starship\.name$'; then fail_with "the map must contain ship.name: starship.name"; fi
if ! echo "$txt" | grep -q '^ *crew\.id: member\.id$'; then fail_with "the map must contain crew.id: member.id"; fi
bad="$(echo "$txt" | awk '/attribute_map:/ {f=1; next} f && /^ *- / {print; exit} {f=0}')"
if [ -n "$bad" ]; then fail_with "attribute_map must be a map, found a list item: $bad"; fi

if [ "$fail" -eq 0 ]; then echo "PASS: Every attribute_map is a map of old to new and all versions are listed"; fi
exit "$fail"
