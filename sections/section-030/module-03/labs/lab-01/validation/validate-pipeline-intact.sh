#!/usr/bin/env bash
# The exporter, the debug exporter and the backend are still in place
set -uo pipefail

OTLP_URL="http://otelcol.observability:4318/v1/traces"
shuttle_curl() { kubectl -n starfleet exec deploy/shuttle -- curl -s --max-time 10 "$@" 2>/dev/null; }
config_text() { kubectl -n observability get configmap otelcol-config -o jsonpath='{.data.config\.yaml}' 2>/dev/null; }
send_span() {
  kubectl -n starfleet exec deploy/shuttle -- curl -s -o /dev/null -w '%{http_code}' --max-time 10 \
    -X POST -H 'Content-Type: application/json' \
    -d "{\"resourceSpans\":[{\"resource\":{\"attributes\":[{\"key\":\"service.name\",\"value\":{\"stringValue\":\"scout\"}}]},\"scopeSpans\":[{\"scope\":{\"name\":\"lab\"},\"spans\":[{\"traceId\":\"$1\",\"spanId\":\"eee19b7ec3c1b174\",\"name\":\"$2\",\"kind\":2,\"startTimeUnixNano\":\"1700000000000000000\",\"endTimeUnixNano\":\"1700000001000000000\"}]}]}]}" \
    "$OTLP_URL" 2>/dev/null
}
new_trace_id() { printf '%08x%08x%08x%08x' "$RANDOM$RANDOM" "$RANDOM$RANDOM" "$RANDOM$RANDOM" "$RANDOM$RANDOM" | cut -c1-32; }
fail=0
fail_with() { echo "FAIL: $1"; fail=1; }
kubectl -n observability rollout status deploy/otelcol --timeout=120s >/dev/null 2>&1
cfg="$(config_text)"
if ! echo "$cfg" | grep -q 'otlp_http/backend:'; then fail_with "the exporter otlp_http/backend is no longer defined"; fi
if ! echo "$cfg" | grep -q 'exporters: \[debug, otlp_http/backend\]'; then fail_with "the traces pipeline must still export to debug and otlp_http/backend"; fi
image="$(kubectl -n observability get deployment backend -o jsonpath='{.spec.template.spec.containers[0].image}' 2>/dev/null)"
if [ "$image" != "otel/opentelemetry-collector-contrib:0.164.0" ]; then fail_with "backend runs image '$image', expected the original image"; fi

if [ "$fail" -eq 0 ]; then echo "PASS: The exporter, the debug exporter and the backend are still in place"; fi
exit "$fail"
