SCRIPT_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")" && pwd)"

setup() {
  SCRIPT="$SCRIPT_DIR/validate-speckit.sh"
  WORK_DIR="$(mktemp -d)"
  cd "$WORK_DIR"
}

teardown() {
  rm -rf "$WORK_DIR"
}

_init_repo() {
  git init -q .
}

_write_extensions() {
  mkdir -p .specify
  printf 'installed: []\nhooks: {}\n' > .specify/extensions.yml
}

@test "exits 1 outside a git repository" {
  run "$SCRIPT"
  [ "$status" -eq 1 ]
  [[ "$output" == *"not a git repository"* ]]
}

@test "exits 1 when .specify/ directory is missing" {
  _init_repo
  run "$SCRIPT"
  [ "$status" -eq 1 ]
  [[ "$output" == *".specify"* ]]
}

@test "exits 1 when extensions.yml is missing" {
  _init_repo
  mkdir -p .specify/memory .specify/specs
  run "$SCRIPT"
  [ "$status" -eq 1 ]
  [[ "$output" == *"extensions.yml"* ]]
}

@test "exits 1 when extensions.yml is invalid yaml" {
  _init_repo
  mkdir -p .specify
  printf 'invalid: yaml: [\n' > .specify/extensions.yml
  run "$SCRIPT"
  [ "$status" -eq 1 ]
}

@test "exits 0 with valid speckit scaffold" {
  _init_repo
  mkdir -p .specify/memory .specify/specs
  _write_extensions
  run "$SCRIPT"
  [ "$status" -eq 0 ]
}
