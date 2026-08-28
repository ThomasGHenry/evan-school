# Plan: validate-commits — GitHub PR suffix tolerance

## Decision

Strip the trailing ` (#NNN)` suffix from a commit subject before applying header-length and subject-case validation. The suffix is a GitHub squash-merge artifact, not authored content; validation should target authored content only.

**Alternatives considered:**

- Reduce budget: document that PR titles must be ≤ 66 chars. Rejected — this is an invisible constraint not enforced at PR creation time, and punishes authors for GitHub's behavior.
- Detect squash-merge by inspecting parent count / commit metadata. Rejected — over-engineered; the regex pattern ` (#[0-9]+)$` is unambiguous and safe to apply to all subjects.

## Files Changed

- `scripts/ci/validate-commits.sh`: add `strip_pr_suffix()` function; apply in `validate_subject()` before all checks.
- `scripts/ci/validate-commits.bats`: add failing test (RED first) then verify GREEN.

## ADR

ADR `0123-validate-commits-pr-suffix.md` — documents the policy decision that ` (#NNN)` suffixes are stripped before header validation.

## CLAUDE.md Update

Add a PR authoring note to the "Key constraints" section of `CLAUDE.md` stating: "PR titles after `type:` must start lowercase (enforced by commitlint + validate-commits.sh)."

## Auto-triage Skip Root Cause

The auto-triage job creates a GitHub issue with labels `acceptance-failure` and `needs-triage`. Neither label exists in the repo because `infra/github/` (Tofu IaC) has not been applied yet — bootstrap is still pending (documented in CLAUDE.md Bootstrap Status section). The `gh issue create` call in `create-issue.sh` fails silently when the labels are absent. This is a known infra gap, not a workflow bug. No code change required; documented here for traceability.

## Implementation Order

1. Write failing BATS test (RED)
2. Run `bats scripts/ci/validate-commits.bats` — confirm failure
3. Add `strip_pr_suffix()` to `validate-commits.sh`
4. Modify `validate_subject()` to use `canonical` form
5. Run `bats scripts/ci/validate-commits.bats` — confirm GREEN
6. Run `bash scripts/ci/run-shellcheck.sh` — confirm no shellcheck errors
7. Write ADR 0123
8. Update CLAUDE.md key constraints section
9. Commit with `fix: strip GitHub PR suffix before commit header validation`
