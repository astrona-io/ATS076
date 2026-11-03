#!/usr/bin/env bash
# The probe receives the b3 header and the X-B3 headers sent through the gateway
set -uo pipefail

shuttle_curl() { kubectl -n starfleet exec deploy/shuttle -- curl -s --max-time 10 "$@" 2>/dev/null; }
fail=0
fail_with() { echo "FAIL: $1"; fail=1; }
kubectl -n starfleet rollout status deploy/gateway --timeout=120s >/dev/null 2>&1
out="$(shuttle_curl http://gateway.starfleet/headers -H 'b3: 80f198ee56343ba864fe8b2a57d3eff7-e457b5a2e4d86bd1-1' -H 'x-b3-traceid: 80f198ee56343ba864fe8b2a57d3eff7' -H 'x-b3-spanid: e457b5a2e4d86bd1' -H 'x-b3-sampled: 1')"
for name in '"B3"' '"X-B3-Traceid"' '"X-B3-Spanid"' '"X-B3-Sampled"'; do
  if ! echo "$out" | grep -q "$name"; then fail_with "the probe did not receive the header $name"; fi
done

if [ "$fail" -eq 0 ]; then echo "PASS: The probe receives the b3 header and the X-B3 headers sent through the gateway"; fi
exit "$fail"
