#!/usr/bin/env bash

set -euo pipefail

ZERO_SHA="0000000000000000000000000000000000000000"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

main() {
  while IFS=' ' read -r _local_ref local_sha _remote_ref remote_sha; do
    _validate_ref "$local_sha" "$remote_sha"
  done
}

_validate_ref() {
  local local_sha="$1" remote_sha="$2"
  [ "$local_sha" = "$ZERO_SHA" ] && return
  [ "$remote_sha" = "$ZERO_SHA" ] && remote_sha="$(_fallback_remote_sha)"
  GITHUB_EVENT_NAME=push \
  GITHUB_EVENT_BEFORE="$remote_sha" \
  GITHUB_SHA="$local_sha" \
    bash "$SCRIPT_DIR/../ci/validate-commits.sh"
}

_fallback_remote_sha() {
  git rev-parse origin/main 2>/dev/null || echo "$ZERO_SHA"
}

main
