#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
readonly SCRIPT_DIR

source "$SCRIPT_DIR/lib/common.sh"

_arg_lcov=""
_arg_package=""
_arg_floor_file=""

main() {
  parse_args "$@"
  validate_args
  ratchet_coverage
}

parse_args() {
  while [ "$#" -gt 0 ]; do
    _parse_flag "$@"
    [[ "$1" =~ ^(--lcov|--package|--floor-file)$ ]] && shift 2 || shift 1
  done
}

validate_args() {
  [ -n "$_arg_lcov" ]       || die "Missing --lcov"
  [ -n "$_arg_package" ]    || die "Missing --package"
  [ -n "$_arg_floor_file" ] || die "Missing --floor-file"
}

ratchet_coverage() {
  local measured floor
  measured=$(_compute_percent "$_arg_lcov")
  floor=$(_read_floor "$_arg_floor_file" "$_arg_package")
  _evaluate "$measured" "$floor"
}

_compute_percent() {
  local lcov_file="$1"
  [ -f "$lcov_file" ] || { echo "0"; return; }
  awk -F: '/^LF:/{t+=$2} /^LH:/{c+=$2} END{print (t>0) ? int(c*100/t) : 0}' "$lcov_file"
}

_read_floor() {
  local floor_file="$1" package="$2"
  [ -f "$floor_file" ] || { echo "0"; return; }
  jq -r --arg p "$package" '.[$p] // 0' "$floor_file"
}

_evaluate() {
  local measured="$1" floor="$2"
  [ "$measured" -lt "$floor" ] && die "Coverage dropped below floor: ${measured}% < ${floor}%"
  [ "$measured" -gt "$floor" ] && { _raise_floor "$measured"; exit 2; }
  log "Coverage at floor: ${measured}% ($_arg_package)"
}

_raise_floor() {
  local measured="$1" updated base
  base="$([ -f "$_arg_floor_file" ] && cat "$_arg_floor_file" || echo '{}')"
  updated=$(printf '%s' "$base" | jq --arg p "$_arg_package" --argjson v "$measured" '.[$p] = $v')
  printf '%s\n' "$updated" > "$_arg_floor_file"
  log "Floor raised: $_arg_package -> ${measured}%"
}

_parse_flag() {
  case "$1" in
  --lcov)       _arg_lcov="${2:-}";       [ -n "$_arg_lcov" ]       || die "Missing lcov value" ;;
  --package)    _arg_package="${2:-}";    [ -n "$_arg_package" ]    || die "Missing package value" ;;
  --floor-file) _arg_floor_file="${2:-}"; [ -n "$_arg_floor_file" ] || die "Missing floor-file value" ;;
  -h|--help)    _print_help; exit 0 ;;
  *)            die "Unknown option: $1" ;;
  esac
}

_print_help() {
  echo "Usage: $0 --lcov <path> --package <name> --floor-file <path>"
}

main "$@"
