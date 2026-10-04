setup() {
  CHECK="$(cd "$(dirname "$BATS_TEST_FILENAME")" && pwd)/check-supply-chain-policy.sh"
  WORK_DIR="$(mktemp -d "$BATS_TMPDIR/supply-chain.XXXXXX")"
  cd "$WORK_DIR"
}

teardown() {
  rm -rf "$WORK_DIR"
}

@test "outside a git repository dies with message" {
  run "$CHECK"
  [ "$status" -eq 1 ]
  [[ "$output" == *"not a git repository"* ]]
}
