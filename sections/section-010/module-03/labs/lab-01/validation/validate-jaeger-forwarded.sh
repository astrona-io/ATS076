#!/usr/bin/env bash
# The probe receives the uber-trace-id header sent through the gateway
set -uo pipefail

shuttle_curl() { kubectl -n starfleet exec deploy/shuttle -- curl -s --max-time 10 "$@" 2>/dev/null; }
fail=0
fail_with() { echo "FAIL: $1"; fail=1; }
kubectl -n starfleet rollout status deploy/gateway --timeout=120s >/dev/null 2>&1
out="$(shuttle_curl http://gateway.starfleet/headers -H 'uber-trace-id: 80f198ee56343ba864fe8b2a57d3eff7:e457b5a2e4d86bd1:0:1')"
if ! echo "$out" | grep -q "80f198ee56343ba864fe8b2a57d3eff7"; then fail_with "the probe did not receive the uber-trace-id value"; fi

if [ "$fail" -eq 0 ]; then echo "PASS: The probe receives the uber-trace-id header sent through the gateway"; fi
exit "$fail"
