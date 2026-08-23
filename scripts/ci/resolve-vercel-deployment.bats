SCRIPT_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")" && pwd)"

setup() {
  SCRIPT="$SCRIPT_DIR/resolve-vercel-deployment.sh"
  MOCK_BIN="$(mktemp -d)/bin"
  mkdir -p "$MOCK_BIN"
  export PATH="$MOCK_BIN:$PATH"
  export VERCEL_TOKEN="tok_test"
  export VERCEL_PROJECT_ID="prj_test"
  export DEPLOYMENT_SHA="abc123"
  export MAX_ATTEMPTS=1
  export POLL_INTERVAL_SECONDS=0
  GITHUB_OUTPUT="$(mktemp)"
  export GITHUB_OUTPUT
  _write_mock_curl READY
}

teardown() {
  rm -rf "$(dirname "$MOCK_BIN")"
  rm -f "$GITHUB_OUTPUT"
}

_write_mock_curl() {
  local state="$1"
  printf '#!/usr/bin/env bash\necho '"'"'{"deployments":[{"uid":"dep_abc","url":"test.vercel.app","readyState":"%s"}]}'"'"'\n' \
    "$state" > "$MOCK_BIN/curl"
  chmod +x "$MOCK_BIN/curl"
}

@test "exits 1 when VERCEL_TOKEN is missing" {
  unset VERCEL_TOKEN
  run "$SCRIPT"
  [ "$status" -eq 1 ]
  [[ "$output" == *"VERCEL_TOKEN"* ]]
}

@test "exits 1 when VERCEL_PROJECT_ID is missing" {
  unset VERCEL_PROJECT_ID
  run "$SCRIPT"
  [ "$status" -eq 1 ]
  [[ "$output" == *"VERCEL_PROJECT_ID"* ]]
}

@test "exits 1 when DEPLOYMENT_SHA is missing" {
  unset DEPLOYMENT_SHA
  run "$SCRIPT"
  [ "$status" -eq 1 ]
  [[ "$output" == *"DEPLOYMENT_SHA"* ]]
}

@test "exits 0 and writes outputs when deployment is READY" {
  run "$SCRIPT"
  [ "$status" -eq 0 ]
  grep -q "deployment-id=dep_abc" "$GITHUB_OUTPUT"
  grep -q "deployment-url=https://test.vercel.app" "$GITHUB_OUTPUT"
}

@test "exits 1 after max attempts with no READY deployment" {
  _write_mock_curl "BUILDING"
  run "$SCRIPT"
  [ "$status" -eq 1 ]
  [[ "$output" == *"no READY deployment"* ]]
}
