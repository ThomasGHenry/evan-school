# Tasks: validate-commits — GitHub PR suffix tolerance

## Phase 1: Red (failing test)

- [x] T1: Add BATS test `"squash-merge PR suffix does not count toward header length"` — commits a 68-char base subject with ` (#999)` appended (75 chars total); asserts validator exits 0. This test currently fails because the validator counts the full 75 chars.
- [x] T2: Run `bats scripts/ci/validate-commits.bats` — confirm T1 is RED (non-zero exit, "header exceeds 72 chars" in output).

## Phase 2: Green (implementation)

- [x] T3: Add `strip_pr_suffix()` function to `validate-commits.sh` — removes trailing ` (#NNN)` pattern using shell parameter expansion.
- [x] T4: Modify `validate_subject()` to compute `canonical="$(strip_pr_suffix "$subject")"` and pass `canonical` to all three check functions.
- [x] T5: Run `bats scripts/ci/validate-commits.bats` — confirm all tests GREEN.

## Phase 3: Refactor + Verify

- [x] T6: Run `bash scripts/ci/run-shellcheck.sh` — confirm no new shellcheck warnings.
- [x] T7: Run `bats scripts/ci/validate-commits.bats` — confirm still GREEN after any refactor.

## Phase 4: Documentation and ADR

- [x] T8: Write ADR `docs/adr/0123-validate-commits-pr-suffix.md`.
- [x] T9: Add PR authoring note to `CLAUDE.md` key constraints section.

## Phase 5: Commit and PR

- [x] T10: Open GitHub issue documenting the defect.
- [x] T11: Commit all changes with conventional commit message ≤ 72 chars.
- [x] T12: Push branch and open PR.
