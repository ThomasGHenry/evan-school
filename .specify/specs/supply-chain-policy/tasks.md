# Tasks: Deliberate supply-chain controls

Plan: `.specify/specs/supply-chain-policy/plan.md`. Each behaviour follows RED (write the
smallest failing test, run it, see it fail, record the failure) → GREEN (minimal code,
run, see it pass) → REFACTOR (clean, run, still passes) → commit. Load the `optimal-bash`
skill before writing any shell. Run `bats scripts/ci/check-supply-chain-policy.bats` at
every step.

Script: `scripts/ci/check-supply-chain-policy.sh` (S). Suite: `scripts/ci/check-supply-chain-policy.bats` (B).
BATS fixtures: each test builds a temp git repo (`mktemp -d "$BATS_TMPDIR/..."`, `git init -q`) as `run-gitleaks.bats` does.

Delivery: one issue → one branch → one PR ("Closes #N"), merged before the next starts.

## Prerequisite (done)

- [x] T000 #71 / PR #72: `next` 15.5.20 → 15.5.24; `pnpm audit --prod --audit-level=critical` red (exit 1, 2 critical) → green (exit 0).

## Slice S1 — remove Renovate, guard against bot config (#66)

- [x] T001 RED: B test "outside a git repository dies with message". Fails: S does not exist.
- [x] T002 GREEN: S skeleton with `SCRIPT_DIR`/`common.sh`, `main`, `require_inside_git_repo`. Same commit adds B (bats-coverage stays green).
- [x] T003 RED: B test "clean repository passes" (empty repo, exit 0). Observed GREEN immediately against the skeleton; kept as a guard.
- [x] T004 GREEN: `main` calls `report_violations`.
- [x] T005 RED: B test "renovate.json present fails naming the file".
- [x] T006 GREEN: `check_no_bot_config` with hardcoded `renovate.json`.
- [x] T007 RED: B tests for each remaining name in plan D1 R1 (`.github/renovate.json`, `.renovaterc`, `.github/dependabot.yml`, ...), one `@test` per name.
- [x] T008 GREEN + REFACTOR: list of forbidden paths; one loop; `add_violation`.
- [x] T009 RED: B test "package.json with top-level renovate key fails".
- [x] T010 GREEN: `python3` json read in `check_no_renovate_package_key`.
- [x] T011 RED (real repo): S in the repo exits 1 naming `renovate.json`.
- [x] T012 GREEN (real repo): delete `renovate.json`, `.github/workflows/renovate.yml`, `scripts/ci/check-renovate-token.sh`, `scripts/ci/check-renovate-token.bats`. S exits 0. Run `validate-bats-coverage.sh`, `run-shellcheck.sh`.
- [x] T013 Wire: `supply-chain-policy` Phase 0 job in `.github/workflows/1-commit.yml`; add to the four Phase 1 `needs:` arrays and `commit-validation` `needs:`. Run `run-actionlint.sh`.
- [x] T014 Docs: remove Renovate setup from `docs/BOOTSTRAP.md`, `docs/github/secrets.md`; `CLAUDE.md` Bootstrap step 4 and Phase 0 job list.

## Slice S2 — pnpm install policy (#67)

- [x] T015 RED: B test "pnpm-workspace.yaml without minimumReleaseAge fails naming the key".
- [x] T016 GREEN: `check_install_policy` reads top-level keys via `python3 yaml.safe_load`.
- [x] T017 RED: B test "minimumReleaseAge 1440 fails (below 10080)". GREEN: numeric comparison.
- [x] T018 RED: B test "minimumReleaseAge nested under security fails" (c60fc00 shape). Observed GREEN on first run; kept as guard.
- [x] T019 RED: B test "missing trustPolicy no-downgrade fails". GREEN.
- [x] T020 RED: B test "missing blockExoticSubdeps true fails". GREEN.
- [x] T021 RED: B test "full top-level policy passes" with a supporting `packageManager`.
- [x] T022 RED: B test "packageManager pnpm@10.25.0 fails (below 10.26.0)". GREEN: `check_pnpm_version` with `sort -V`.
- [x] T023 RED: B test "packageManager with integrity suffix at supported version passes". Observed GREEN on first run; kept as guard (10.26.0 boundary covered by "full top-level install policy passes").
- [x] T024 RED: B test ".npmrc containing shamefully-hoist fails". GREEN: `check_settings_location`.
- [x] T025 RED: B test "missing top-level shamefullyHoist true fails". GREEN.
- [x] T026 REFACTOR: extract thresholds as readonly constants; run B.
- [x] T027 RED (real repo): S exits 1 naming `minimumReleaseAge`, `trustPolicy`, `blockExoticSubdeps`, `packageManager`, `shamefully-hoist`.
- [x] T028 GREEN (real repo): re-verify `npm view pnpm time`; `packageManager` to newest 10.x >= 7 days old; add the four top-level keys; remove `shamefully-hoist=true` from `.npmrc` (delete `.npmrc` if empty); `pnpm install --frozen-lockfile`; `pnpm run typecheck lint test build`. S exits 0.

## Slice S3 — SHA-pinned actions (#68)

- [x] T029 RED: B test "workflow with actions/checkout@v4 fails naming file:line and ref". GREEN: `check_action_pins`.
- [x] T030 RED: B test "uses pinned to 40-hex sha passes".
- [x] T031 RED: B test "local ./ action passes".
- [x] T032 RED: B test "short 7-hex sha fails". Observed GREEN on first run; kept as guard.
- [x] T033 RED: B test "sha followed by trailing text fails" (no-comments rule). Observed GREEN on first run; kept as guard.
- [x] T034 RED: B test "composite action.yml under .github/actions is scanned".
- [x] T035 GREEN + REFACTOR after each of T030-T034; run B.
- [x] T036 RED (real repo): S exits 1 listing every tag-pinned `uses:`.
- [x] T037 GREEN (real repo): resolve each tag with `env -u GH_TOKEN gh api repos/OWNER/REPO/git/ref/tags/TAG`, dereferencing annotated tags to the commit; rewrite as `owner/repo@<sha>`; record the tag→SHA map in the PR body. S exits 0; `run-actionlint.sh` passes.

## Slice S4 — pnpm audit gate (#69)

- [x] T038 RED (real repo): `pnpm audit --prod --audit-level=high` exits 1; record counts and advisory list.
- [x] T039 GREEN (real repo): deliberate updates for fixable advisories whose patched version is >= 7 days old; add the rest to `auditConfig.ignoreGhsas`; record each in ADR 0124 Audit Ignore List with reason and review date. Audit exits 0. `pnpm run typecheck lint test build`.
- [x] T040 Wire: `pnpm-audit` Phase 0 job (plan D2: non-blocking `--dev` step, blocking `--prod` step) with SHA-pinned `uses:`; add to the four Phase 1 `needs:` and `commit-validation` `needs:`. Run `run-actionlint.sh` and S.

## Slice S5 — governance close-out

- [ ] T041 `.specify/memory/constitution.md`: CI Gate list, pnpm Tech Stack row, non-negotiables 15/16.
- [ ] T042 `.github/LABEL_TAXONOMY.md:20` and `infra/github/main.tf:94` description: drop Renovate reference (Tofu applies via pipeline).
- [ ] T043 ADR 0124 → `status: accepted`, `implementation: scripts/ci/check-supply-chain-policy.sh`, `## Findings`. Run `validate-adrs.sh docs/adr`.
- [ ] T044 `/qreview` against the completeness surface; `bats scripts/ci/*.bats`; close #65 when #66-#69 are closed.
