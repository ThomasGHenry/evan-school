---
status: accepted
date: 2026-08-28
tags: [tooling, ci, commits]
implementation: scripts/ci/validate-commits.sh
---

# 0123. Strip GitHub squash-merge PR suffix before commit header validation

## Context

GitHub appends ` (#NNN)` to the commit subject when squash-merging a pull request.
A PR title of 71 characters becomes a commit subject of 78 characters, breaching
the 72-character header maximum enforced by `validate-commits.sh`.

Commit `24eb5c6` exposed this: PR title was 71 chars; GitHub added ` (#54)`, making
the subject 76 chars. The CI `validate-commits` job failed with "header exceeds 72
chars (76)".

The suffix is a GitHub-generated artifact, not authored content. Applying the 72-char
limit to non-authored content produces false positives and erodes trust in the gate.

## Decision

We strip the trailing ` (#NNN)` suffix from the commit subject before applying all
validation checks in `validate_subject()`. The 72-character budget applies to the
authored PR title; GitHub's suffix is excluded from the measurement.

The `strip_pr_suffix()` function uses shell parameter expansion
`"${subject% (#[0-9]*)}"` to remove the pattern. This is a trailing-match removal;
it cannot strip a mid-subject occurrence of the pattern.

Authoring constraint (unchanged): PR titles must start lowercase after the type
prefix. Example: `docs: seo/geo/aeo` not `docs: SEO/GEO/AEO`. This is unaffected
by suffix stripping and remains enforced at validation time.

## Consequences

- Authors may use up to 72 characters in their PR titles without CI failure.
- The practical safe budget before the fix was unpredictable (depended on PR number
  length). After the fix, the budget is the documented 72 characters.
- Commits authored directly (not via GitHub squash-merge) are unaffected; the strip
  is a no-op when the pattern is absent.
- All seven existing BATS test cases continue to pass; one new case was added for
  this scenario.
