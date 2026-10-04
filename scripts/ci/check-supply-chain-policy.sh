#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

readonly FORBIDDEN_BOT_CONFIGS=(
  renovate.json renovate.json5 .renovaterc .renovaterc.json .renovaterc.json5
  .github/renovate.json .github/renovate.json5 .gitlab/renovate.json .gitlab/renovate.json5
  .github/dependabot.yml .github/dependabot.yaml
)

REPO_ROOT=""

main() {
  require_inside_git_repo
  REPO_ROOT="$(git rev-parse --show-toplevel)"
  check_no_bot_config
  check_no_renovate_package_key
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

_reject_if_present() {
  [ ! -e "$REPO_ROOT/$1" ] || add_violation "$1: automated dependency-update bot config is forbidden"
}

_json_has_top_level_key() {
  python3 -c 'import json,sys; sys.exit(0 if sys.argv[2] in json.load(open(sys.argv[1])) else 1)' "$1" "$2"
}

main "$@"
