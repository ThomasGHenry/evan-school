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
  report_violations
}

check_no_bot_config() {
  local path
  for path in "${FORBIDDEN_BOT_CONFIGS[@]}"; do
    _reject_if_present "$path"
  done
}

_reject_if_present() {
  [ ! -e "$REPO_ROOT/$1" ] || add_violation "$1: automated dependency-update bot config is forbidden"
}

main "$@"
