#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

VERCEL_API_BASE="${VERCEL_API_BASE:-https://api.vercel.com}"
MAX_ATTEMPTS="${MAX_ATTEMPTS:-30}"
POLL_INTERVAL_SECONDS="${POLL_INTERVAL_SECONDS:-10}"

main() {
  _require_env VERCEL_TOKEN
  _require_env VERCEL_PROJECT_ID
  _require_env DEPLOYMENT_SHA
  local deployment_json
  deployment_json="$(_poll_for_ready_deployment)"
  _emit_deployment_outputs "$deployment_json"
}

_poll_for_ready_deployment() {
  local attempt result
  for ((attempt = 1; attempt <= MAX_ATTEMPTS; attempt++)); do
    result="$(_check_deployment_state "$attempt")" && { printf '%s' "$result"; return 0; }
    sleep "$POLL_INTERVAL_SECONDS"
  done
  die "no READY deployment found for sha $DEPLOYMENT_SHA after $MAX_ATTEMPTS attempts"
}

_check_deployment_state() {
  local attempt="$1" deployment_json ready_state
  deployment_json="$(_fetch_deployments)"
  ready_state="$(_deployment_field "$deployment_json" readyState)"
  log "attempt $attempt/$MAX_ATTEMPTS: readyState=$ready_state" >&2
  [ "$ready_state" = "READY" ] && printf '%s' "$deployment_json"
}

_fetch_deployments() {
  curl -sS \
    -H "Authorization: Bearer ${VERCEL_TOKEN}" \
    "${VERCEL_API_BASE}/v7/deployments?projectId=${VERCEL_PROJECT_ID}&sha=${DEPLOYMENT_SHA}&limit=1"
}

_emit_deployment_outputs() {
  local deployment_json="$1" deployment_id deployment_url
  deployment_id="$(_deployment_field "$deployment_json" uid)"
  deployment_url="$(_deployment_field "$deployment_json" url)"
  _write_step_output "deployment-id" "$deployment_id"
  _write_step_output "deployment-url" "https://$deployment_url"
}

_deployment_field() {
  jq -r ".deployments[0].$2" <<< "$1"
}

_write_step_output() {
  printf '%s=%s\n' "$1" "$2" >> "${GITHUB_OUTPUT:-/dev/null}"
}

_require_env() {
  local name="$1"
  [ -n "${!name:-}" ] || die "$name environment variable is required"
}

main "$@"
