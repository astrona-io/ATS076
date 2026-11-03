#!/usr/bin/env bash
# The exporter reports no failed spans
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
TRACE="$(new_trace_id)"
code="$(send_span "$TRACE" "lab-count-$RANDOM")"
if [ "$code" != "200" ]; then fail_with "the Collector answered HTTP '$code' on port 4318, expected 200"; fi
sleep 8
metrics="$(shuttle_curl http://otelcol.observability:8888/metrics)"
if ! echo "$metrics" | grep -q 'otelcol_exporter_sent_spans'; then fail_with "otelcol_exporter_sent_spans is not reported yet; no span was sent by the exporter"; fi
failed="$(echo "$metrics" | grep '^otelcol_exporter_send_failed_spans' | grep 'otlp_http/backend' | awk '{s+=$NF} END {print s+0}')"
if [ "$failed" != "0" ]; then fail_with "otelcol_exporter_send_failed_spans for otlp_http/backend is $failed, expected 0"; fi

if [ "$fail" -eq 0 ]; then echo "PASS: The exporter reports no failed spans"; fi
exit "$fail"
