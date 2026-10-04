#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

readonly FORBIDDEN_BOT_CONFIGS=(
  renovate.json renovate.json5 .renovaterc .renovaterc.json .renovaterc.json5
  .github/renovate.json .github/renovate.json5 .gitlab/renovate.json .gitlab/renovate.json5
  .github/dependabot.yml .github/dependabot.yaml
)

readonly MIN_RELEASE_AGE_MINUTES=10080

REPO_ROOT=""

main() {
  require_inside_git_repo
  REPO_ROOT="$(git rev-parse --show-toplevel)"
  check_no_bot_config
  check_no_renovate_package_key
  check_install_policy
  report_violations
}

check_no_bot_config() {
  local path
  for path in "${FORBIDDEN_BOT_CONFIGS[@]}"; do
    _reject_if_present "$path"
  done
}

check_no_renovate_package_key() {
  local manifest="$REPO_ROOT/package.json"
  [ -f "$manifest" ] || return 0
  _json_has_top_level_key "$manifest" renovate || return 0
  add_violation "package.json: top-level 'renovate' key is forbidden"
}

check_install_policy() {
  local workspace="$REPO_ROOT/pnpm-workspace.yaml"
  [ -f "$workspace" ] || return 0
  _require_release_cooldown "$workspace"
  _require_setting "$workspace" trustPolicy no-downgrade
}

_reject_if_present() {
  [ ! -e "$REPO_ROOT/$1" ] || add_violation "$1: automated dependency-update bot config is forbidden"
}

_json_has_top_level_key() {
  python3 -c 'import json,sys; sys.exit(0 if sys.argv[2] in json.load(open(sys.argv[1])) else 1)' "$1" "$2"
}

_require_release_cooldown() {
  local age
  age="$(_yaml_top_level_value "$1" minimumReleaseAge)"
  [[ "$age" =~ ^[0-9]+$ ]] && [ "$age" -ge "$MIN_RELEASE_AGE_MINUTES" ] && return 0
  add_violation "pnpm-workspace.yaml: top-level 'minimumReleaseAge' must be >= $MIN_RELEASE_AGE_MINUTES (got: ${age:-missing})"
}

_require_setting() {
  local actual
  actual="$(_yaml_top_level_value "$1" "$2")"
  [ "$actual" = "$3" ] || add_violation "pnpm-workspace.yaml: top-level '$2' must be '$3' (got: ${actual:-missing})"
}

_yaml_top_level_value() {
  python3 -c 'import sys,yaml; d=yaml.safe_load(open(sys.argv[1])) or {}; v=d.get(sys.argv[2]); print("" if v is None else str(v).lower() if isinstance(v,bool) else v)' "$1" "$2"
}

main "$@"
