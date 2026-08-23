SCRIPT_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")" && pwd)"

setup() {
  SCRIPT="$SCRIPT_DIR/ratchet-coverage.sh"
  WORK_DIR="$(mktemp -d)"
  LCOV_FILE="$WORK_DIR/lcov.info"
  FLOOR_FILE="$WORK_DIR/coverage_floor.json"
  echo '{"web":80}' > "$FLOOR_FILE"
  _write_lcov 100 80
}

teardown() {
  rm -rf "$WORK_DIR"
}

_write_lcov() {
  local total="$1" covered="$2"
  printf 'SF:apps/web/src/index.ts\nLF:%s\nLH:%s\nend_of_record\n' \
    "$total" "$covered" > "$LCOV_FILE"
}

@test "exits 0 when coverage equals floor" {
  run "$SCRIPT" --lcov "$LCOV_FILE" --package web --floor-file "$FLOOR_FILE"
  [ "$status" -eq 0 ]
}

@test "exits 2 and updates floor when coverage improves" {
  _write_lcov 100 90
  run "$SCRIPT" --lcov "$LCOV_FILE" --package web --floor-file "$FLOOR_FILE"
  [ "$status" -eq 2 ]
  result="$(jq -r '.web' "$FLOOR_FILE")"
  [ "$result" -eq 90 ]
}

@test "exits 1 when coverage drops below floor" {
  _write_lcov 100 70
  run "$SCRIPT" --lcov "$LCOV_FILE" --package web --floor-file "$FLOOR_FILE"
  [ "$status" -eq 1 ]
  [[ "$output" == *"dropped below"* ]]
}

@test "treats missing floor key as zero and raises floor" {
  echo '{}' > "$FLOOR_FILE"
  _write_lcov 100 55
  run "$SCRIPT" --lcov "$LCOV_FILE" --package web --floor-file "$FLOOR_FILE"
  [ "$status" -eq 2 ]
  result="$(jq -r '.web' "$FLOOR_FILE")"
  [ "$result" -eq 55 ]
}

@test "treats missing lcov as zero coverage at zero floor" {
  echo '{}' > "$FLOOR_FILE"
  run "$SCRIPT" --lcov "$WORK_DIR/missing.info" --package web --floor-file "$FLOOR_FILE"
  [ "$status" -eq 0 ]
}

@test "fails when required args are missing" {
  run "$SCRIPT" --package web --floor-file "$FLOOR_FILE"
  [ "$status" -ne 0 ]
}

@test "creates floor file when it does not exist and coverage is above zero" {
  local new_floor="$WORK_DIR/new_floor.json"
  _write_lcov 100 65
  run "$SCRIPT" --lcov "$LCOV_FILE" --package web --floor-file "$new_floor"
  [ "$status" -eq 2 ]
  [ -f "$new_floor" ]
  result="$(jq -r '.web' "$new_floor")"
  [ "$result" -eq 65 ]
}
