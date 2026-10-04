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

@test "clean repository passes" {
  git init -q .
  run "$CHECK"
  [ "$status" -eq 0 ]
}

@test "renovate.json present fails naming the file" {
  git init -q .
  printf '{}\n' > renovate.json
  run "$CHECK"
  [ "$status" -eq 1 ]
  [[ "$output" == *"renovate.json"* ]]
}

plant_file() {
  mkdir -p "$(dirname "$1")"
  printf '{}\n' > "$1"
}

@test "renovate.json5 present fails naming the file" {
  git init -q .
  plant_file renovate.json5
  run "$CHECK"
  [ "$status" -eq 1 ]
  [[ "$output" == *"renovate.json5"* ]]
}

@test ".renovaterc present fails naming the file" {
  git init -q .
  plant_file .renovaterc
  run "$CHECK"
  [ "$status" -eq 1 ]
  [[ "$output" == *".renovaterc"* ]]
}

@test ".renovaterc.json present fails naming the file" {
  git init -q .
  plant_file .renovaterc.json
  run "$CHECK"
  [ "$status" -eq 1 ]
  [[ "$output" == *".renovaterc.json"* ]]
}

@test ".renovaterc.json5 present fails naming the file" {
  git init -q .
  plant_file .renovaterc.json5
  run "$CHECK"
  [ "$status" -eq 1 ]
  [[ "$output" == *".renovaterc.json5"* ]]
}

@test ".github/renovate.json present fails naming the file" {
  git init -q .
  plant_file .github/renovate.json
  run "$CHECK"
  [ "$status" -eq 1 ]
  [[ "$output" == *".github/renovate.json"* ]]
}

@test ".github/renovate.json5 present fails naming the file" {
  git init -q .
  plant_file .github/renovate.json5
  run "$CHECK"
  [ "$status" -eq 1 ]
  [[ "$output" == *".github/renovate.json5"* ]]
}

@test ".gitlab/renovate.json present fails naming the file" {
  git init -q .
  plant_file .gitlab/renovate.json
  run "$CHECK"
  [ "$status" -eq 1 ]
  [[ "$output" == *".gitlab/renovate.json"* ]]
}

@test ".gitlab/renovate.json5 present fails naming the file" {
  git init -q .
  plant_file .gitlab/renovate.json5
  run "$CHECK"
  [ "$status" -eq 1 ]
  [[ "$output" == *".gitlab/renovate.json5"* ]]
}

@test ".github/dependabot.yml present fails naming the file" {
  git init -q .
  plant_file .github/dependabot.yml
  run "$CHECK"
  [ "$status" -eq 1 ]
  [[ "$output" == *".github/dependabot.yml"* ]]
}

@test ".github/dependabot.yaml present fails naming the file" {
  git init -q .
  plant_file .github/dependabot.yaml
  run "$CHECK"
  [ "$status" -eq 1 ]
  [[ "$output" == *".github/dependabot.yaml"* ]]
}

@test "package.json with top-level renovate key fails" {
  git init -q .
  printf '{"name":"x","renovate":{"extends":["config:recommended"]}}\n' > package.json
  run "$CHECK"
  [ "$status" -eq 1 ]
  [[ "$output" == *"package.json"*"renovate"* ]]
}

@test "package.json without renovate key passes" {
  git init -q .
  printf '{"name":"x","dependencies":{"renovate-like":"1.0.0"}}\n' > package.json
  run "$CHECK"
  [ "$status" -eq 0 ]
}
