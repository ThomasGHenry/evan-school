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
readonly MIN_PNPM_VERSION=10.26.0

REPO_ROOT=""

main() {
  require_inside_git_repo
  REPO_ROOT="$(git rev-parse --show-toplevel)"
  check_bot_config_absent
  check_pnpm_policy
  check_action_pins
  report_violations
}

check_bot_config_absent() {
  check_no_bot_config_files
  check_no_renovate_package_key
}

check_pnpm_policy() {
  check_workspace_settings
  check_pnpm_version
  check_npmrc_settings
}

check_no_bot_config_files() {
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

check_workspace_settings() {
  local workspace="$REPO_ROOT/pnpm-workspace.yaml"
  [ -f "$workspace" ] || return 0
  _require_install_policy "$workspace"
  _require_setting "$workspace" shamefullyHoist true
}

check_pnpm_version() {
  local manifest="$REPO_ROOT/package.json" version
  [ -f "$manifest" ] || return 0
  version="$(_pnpm_version_of "$manifest")"
  _version_at_least "$version" "$MIN_PNPM_VERSION" || add_violation "package.json: packageManager pnpm must be >= $MIN_PNPM_VERSION (got: ${version:-missing})"
}

check_npmrc_settings() {
  local npmrc="$REPO_ROOT/.npmrc"
  [ -f "$npmrc" ] || return 0
  ! grep -q 'shamefully-hoist' "$npmrc" || add_violation ".npmrc: 'shamefully-hoist' belongs in pnpm-workspace.yaml as 'shamefullyHoist'"
}

check_action_pins() {
  local finding
  while IFS= read -r finding; do
    add_violation "$finding: remote action must be pinned to a full commit SHA"
  done < <(_list_action_refs)
}

_reject_if_present() {
  [ ! -e "$REPO_ROOT/$1" ] || add_violation "$1: automated dependency-update bot config is forbidden"
}

_json_has_top_level_key() {
  python3 -c 'import json,sys; sys.exit(0 if sys.argv[2] in json.load(open(sys.argv[1])) else 1)' "$1" "$2"
}

_require_install_policy() {
  _require_release_cooldown "$1"
  _require_setting "$1" trustPolicy no-downgrade
  _require_setting "$1" blockExoticSubdeps true
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

_pnpm_version_of() {
  local spec
  spec="$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1])).get("packageManager",""))' "$1")"
  [[ "$spec" == pnpm@* ]] || return 0
  spec="${spec#pnpm@}"
  printf '%s\n' "${spec%%+*}"
}

_version_at_least() {
  [ -n "$1" ] || return 1
  [ "$(printf '%s\n%s\n' "$2" "$1" | sort -V | head -1)" = "$2" ]
}

_list_action_refs() {
  ( cd "$REPO_ROOT" && grep -HnE '^[[:space:]-]*uses:' .github/workflows/*.y*ml 2>/dev/null || true ) | sed -E 's/^([^:]+:[0-9]+):[[:space:]-]*uses:[[:space:]]*/\1 /'
}

_yaml_top_level_value() {
  python3 -c 'import sys,yaml; d=yaml.safe_load(open(sys.argv[1])) or {}; v=d.get(sys.argv[2]); print("" if v is None else str(v).lower() if isinstance(v,bool) else v)' "$1" "$2"
}

main "$@"
