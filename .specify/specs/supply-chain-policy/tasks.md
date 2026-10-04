# Tasks: Deliberate supply-chain controls

Plan: `.specify/specs/supply-chain-policy/plan.md`. Each behaviour follows RED (write the
smallest failing test, run it, see it fail) → GREEN (minimal code, run, see it pass) →
REFACTOR (clean, run, still passes) → commit. Load the `optimal-bash` skill before
writing any shell. Run `bats scripts/ci/check-supply-chain-policy.bats` at every step.

Script: `scripts/ci/check-supply-chain-policy.sh` (S). Suite: `scripts/ci/check-supply-chain-policy.bats` (B).
BATS fixtures: each test builds a temp git repo (`mktemp -d "$BATS_TMPDIR/..."`, `git init -q`) as `run-gitleaks.bats` does.

## Slice S1 — remove Renovate, guard against bot config (#66)

- [ ] T001 RED: B test "outside a git repository dies with message". Fails: S does not exist.
- [ ] T002 GREEN: S skeleton with `SCRIPT_DIR`/`common.sh`, `main`, `require_inside_git_repo`. Same commit adds B (bats-coverage stays green).
- [ ] T003 RED: B test "clean repository passes" (empty repo, exit 0).
- [ ] T004 GREEN: `main` calls `report_violations`.
- [ ] T005 RED: B test "renovate.json present fails naming the file".
- [ ] T006 GREEN: `check_no_bot_config` with hardcoded `renovate.json`.
- [ ] T007 RED: B data-driven tests for each remaining name in plan D1 R1 (`.github/renovate.json`, `.renovaterc`, `.github/dependabot.yml`, ...), one `@test` per name.
- [ ] T008 GREEN + REFACTOR: list of forbidden paths; one loop; `add_violation`.
- [ ] T009 RED: B test "package.json with top-level renovate key fails".
- [ ] T010 GREEN: `python3` json read in `check_no_renovate_package_key`.
- [ ] T011 RED (real repo): `bash scripts/ci/check-supply-chain-policy.sh` in the repo exits 1 naming `renovate.json`.
- [ ] T012 GREEN (real repo): delete `renovate.json`, `.github/workflows/renovate.yml`, `scripts/ci/check-renovate-token.sh`, `scripts/ci/check-renovate-token.bats`. Re-run S: exit 0. Run `validate-bats-coverage.sh`, `run-shellcheck.sh`.
- [ ] T013 Wire: add `supply-chain-policy` Phase 0 job to `.github/workflows/1-commit.yml`; add it to the four Phase 1 `needs:` arrays and to `commit-validation` `needs:`. Run `run-actionlint.sh`.
- [ ] T014 Docs: remove Renovate setup from `docs/BOOTSTRAP.md:174-188,252`, `docs/github/secrets.md:12`; `CLAUDE.md` Bootstrap step 4 and Phase 0 job list.

## Slice S2 — 7-day pnpm cooldown (#67)

- [ ] T015 RED: B test "pnpm-workspace.yaml without minimumReleaseAge fails naming the key".
- [ ] T016 GREEN: `check_release_cooldown` reads top-level key via `python3 yaml.safe_load`.
- [ ] T017 RED: B test "minimumReleaseAge 1440 fails (below 10080)".
- [ ] T018 GREEN: numeric comparison against `10080`.
- [ ] T019 RED: B test "minimumReleaseAge nested under security fails" (c60fc00 shape).
- [ ] T020 GREEN: confirm top-level-only lookup (may already pass; if so the test is a guard, record it).
- [ ] T021 RED: B test "minimumReleaseAge 10080 top-level passes" alongside a supporting `packageManager`.
- [ ] T022 RED: B test "packageManager pnpm@10.11.0 fails (below 10.16.0)".
- [ ] T023 GREEN: `check_pnpm_supports_cooldown` with version compare (`sort -V`).
- [ ] T024 RED: B test "packageManager pnpm@10.16.0 passes".
- [ ] T025 REFACTOR: extract version/threshold constants; run B.
- [ ] T026 RED (real repo): S exits 1 naming `minimumReleaseAge` and `packageManager`.
- [ ] T027 GREEN (real repo): set `packageManager` to the newest pnpm 10.x published >= 7 days earlier (plan D3); add top-level `minimumReleaseAge: 10080` to `pnpm-workspace.yaml` (plus Q2 keys if approved); `pnpm install --frozen-lockfile` locally. S exits 0.

## Slice S3 — SHA-pinned actions (#68)

- [ ] T028 RED: B test "workflow with actions/checkout@v4 fails naming file:line and ref".
- [ ] T029 GREEN: `check_action_pins` scanning `uses:` lines with a 40-hex regex.
- [ ] T030 RED: B test "uses pinned to 40-hex sha with trailing tag comment passes".
- [ ] T031 RED: B test "local ./ action passes".
- [ ] T032 RED: B test "short 7-hex sha fails".
- [ ] T033 RED: B test "composite action.yml under .github/actions is scanned".
- [ ] T034 GREEN + REFACTOR after each of T030-T033; run B.
- [ ] T035 RED (real repo): S exits 1 listing every tag-pinned `uses:` (expected 49 refs across `.github/workflows/`).
- [ ] T036 GREEN (real repo): resolve each tag to its commit SHA via `env -u GH_TOKEN gh api repos/<owner>/<repo>/commits/<tag> --jq .sha`; rewrite as `owner/repo@<sha> # <tag>`. S exits 0; `run-actionlint.sh` passes.

## Slice S4 — pnpm audit gate (#69), after Q1 is answered

- [ ] T037 RED (real repo): `pnpm audit --audit-level=high [--prod per Q1]` exits 1 (observed on `1c9ef82`: 59 high / 2 critical; `--prod` 20 high / 2 critical).
- [ ] T038 GREEN (real repo): bump `next` to `>=15.5.24`; deliberate `pnpm update` of affected packages; allowlist per Q1 for advisories with no patch. Re-run audit: exit 0. Run `pnpm run typecheck lint test build`.
- [ ] T039 Wire: add `pnpm-audit` Phase 0 job (inline step, plan D2) to `1-commit.yml`; add to the four Phase 1 `needs:` and `commit-validation` `needs:`. Run `run-actionlint.sh` and S (new `uses:` must be SHA-pinned; S fails otherwise, which is the R4 guard working).

## Slice S5 — governance close-out

- [ ] T040 `.github/LABEL_TAXONOMY.md:20` and `.specify/memory/constitution.md` CI Gate list + non-negotiables 15/16 per Q3.
- [ ] T041 ADR 0124 → `status: accepted`, `implementation: scripts/ci/check-supply-chain-policy.sh`; add `## Findings`. Run `validate-adrs.sh docs/adr`.
- [ ] T042 `/qreview` against the plan's completeness surface; `bats scripts/ci/*.bats`.
- [ ] T043 Upstream note to ThomasGHenry/tgh-template (issue filed during Phase A).
