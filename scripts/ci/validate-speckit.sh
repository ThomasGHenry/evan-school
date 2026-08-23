#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

REPO_ROOT=""

main() {
  require_inside_git_repo
  REPO_ROOT="$(git rev-parse --show-toplevel)"
  check_structure
  check_extensions_yml
}

check_structure() {
  [ -d "$REPO_ROOT/.specify" ] || die ".specify/ directory is missing — run speckit constitution phase"
}

check_extensions_yml() {
  local ext="$REPO_ROOT/.specify/extensions.yml"
  [ -f "$ext" ] || die ".specify/extensions.yml is missing"
  python3 -c "import yaml,sys; yaml.safe_load(sys.stdin)" < "$ext" || die ".specify/extensions.yml is not valid YAML"
}

main "$@"
