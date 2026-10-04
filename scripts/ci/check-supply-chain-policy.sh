#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

main() {
  require_inside_git_repo
  check_no_bot_config
  report_violations
}

check_no_bot_config() {
  [ ! -e renovate.json ] || add_violation "renovate.json: automated dependency-update bot config is forbidden"
}

main "$@"
