#!/usr/bin/env bash
# The gateway still removes x-internal-debug and still proxies
set -uo pipefail

shuttle_curl() { kubectl -n starfleet exec deploy/shuttle -- curl -s --max-time 10 "$@" 2>/dev/null; }
fail=0
fail_with() { echo "FAIL: $1"; fail=1; }
kubectl -n starfleet rollout status deploy/gateway --timeout=120s >/dev/null 2>&1
out="$(shuttle_curl http://gateway.starfleet/headers -H 'x-internal-debug: on' -H 'x-request-check: present')"
if ! echo "$out" | grep -q 'present'; then fail_with "the probe did not receive the control header x-request-check"; fi
if echo "$out" | grep -qi 'X-Internal-Debug'; then fail_with "the probe received x-internal-debug, which the gateway must remove"; fi
code="$(shuttle_curl -o /dev/null -w '%{http_code}' http://gateway.starfleet/status/204)"
if [ "$code" != "204" ]; then fail_with "GET /status/204 through the gateway returned '$code', expected 204"; fi
image="$(kubectl -n starfleet get deployment gateway -o jsonpath='{.spec.template.spec.containers[0].image}' 2>/dev/null)"
if [ "$image" != "nginx:1.29-alpine" ]; then fail_with "gateway runs image '$image', expected 'nginx:1.29-alpine'"; fi

if [ "$fail" -eq 0 ]; then echo "PASS: The gateway still removes x-internal-debug and still proxies"; fi
exit "$fail"
