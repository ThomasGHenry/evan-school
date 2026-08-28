# Spec: validate-commits — GitHub PR suffix tolerance

## Feature

As a developer whose pull request is squash-merged by GitHub, I want commit validation to not penalize the ` (#NNN)` suffix that GitHub automatically appends to the squash-merge commit subject, so that my PR title of ≤ 72 characters does not fail CI due to GitHub's added suffix.

## Background

GitHub appends ` (#NNN)` (space, open-paren, hash, PR number, close-paren) to the squash-merge commit subject. A PR title of 71 characters becomes a commit subject of 76+ characters, breaching the 72-character header limit enforced by `validate-commits.sh`. This is a systemic defect that silently breaks CI for any PR where `title_length + len(" (#NNN)")` exceeds 72.

The failure on commit `24eb5c686c618af7a81b9e814657253560aea72b` exposed both this systemic issue and a separate authoring discipline failure (uppercase subject "SEO/GEO/AEO"). The fix addresses the systemic issue; the authoring constraint is documented separately.

## Success Criteria

- SC1: A commit subject whose base (pre-suffix) form is ≤ 72 characters passes header length validation even when the full subject exceeds 72 characters due to an appended ` (#NNN)` suffix.
- SC2: A commit subject whose base form is > 72 characters fails header length validation regardless of any suffix.
- SC3: Subject case validation (no uppercase after type prefix) is applied to the base form, not the suffix-appended form.
- SC4: All currently-passing BATS tests continue to pass.
- SC5: A merge commit with a standard GitHub merge format is still skipped as before.

## Out of Scope

- Changing the 72-character limit itself.
- Enforcing lowercase subjects automatically (authoring discipline only — documented in CLAUDE.md PR checklist).
- Modifying how commitlint behaves at the `commit-msg` hook stage.

## Authoring Constraint (Non-functional)

PR titles must start with lowercase after the `type:` prefix. Example: `docs: seo/geo/aeo stack decisions` not `docs: SEO/GEO/AEO stack decisions`. This is enforced at validation time and cannot be auto-corrected by the suffix-stripping fix. A pre-merge checklist note is added to CLAUDE.md.
