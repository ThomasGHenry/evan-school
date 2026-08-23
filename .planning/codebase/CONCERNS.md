# Codebase Concerns

**Analysis Date:** 2026-06-28

---

## Bootstrap Gaps

**Tofu IaC never applied — branch protection and labels absent:**
- Risk: HIGH
- Issue: `infra/github/` has been written but never run. Branch protection ruleset (`github_repository_ruleset.main_protection`), 14 custom labels, and `production`/`preview` environments do not exist on GitHub.
- Files: `infra/github/main.tf:38-105`, `infra/github/backend.tf:4`
- Blocker: `infra/github/backend.tf` line 4 contains a literal placeholder: `bucket = "TODO-configure-your-gcs-bucket-name"` — `tofu init` will fail until replaced.
- Impact: Direct pushes to `main` are not blocked. The "Commit Validation" required status check is not enforced. Auto-merge cannot activate without the ruleset. Label taxonomy used in issue templates does not exist.
- Fix approach: Create GCS bucket, update `backend.tf` line 4, set `TF_VAR_github_token`, run `cd infra/github && tofu init && tofu plan && tofu apply`.

**Vercel secrets absent — `2-e2e` and `3-promote` workflows will fail:**
- Risk: HIGH
- Issue: Three repository secrets are required but not set: `VERCEL_TOKEN`, `VERCEL_PREVIEW_URL`, `DATABASE_URL_PROD`.
- Files: `.github/workflows/2-e2e.yml:24`, `.github/workflows/3-promote.yml:49,51`
- Impact: When `1-commit` passes on `main`, `2-e2e` triggers via `workflow_run` and immediately fails attempting to reach `${{ secrets.VERCEL_PREVIEW_URL }}`. `3-promote` is blocked transitively. DORA metrics via `incident.yml` will also be inaccurate.
- Fix approach: Create Vercel project, link to repo, populate secrets in GitHub repository settings before first real `main` push.

**Repository is private — PRD requires public:**
- Risk: MEDIUM
- Issue: ADR 0001 (`docs/adr/0001-snapshot-model.md`) and `infra/github/main.tf` line 19 (`visibility = "public"`) specify the repo must be public. Current GitHub state is private.
- Fix approach: Resolved automatically by Tofu apply (same as gap 1 above).

**Renovate token not set — dependency automation silently disabled:**
- Risk: LOW
- Issue: `renovate.yml` requires `RENOVATE_TOKEN`. The `check-renovate-token.sh` guard prevents a hard failure — the workflow silently skips all steps when the secret is absent. Dependency updates accumulate without automation.
- Files: `.github/workflows/renovate.yml:18`, `scripts/ci/check-renovate-token.sh`
- Fix approach: Create fine-grained PAT, add as `RENOVATE_TOKEN` secret.

---

## Git Hot Spots

**`.github/workflows/1-commit.yml` — highest churn (6 changes in 16 commits):**
- Risk: MEDIUM
- Changes across commits: `768c93a`, `16be9ec`, `cfafcbf`, `23c7139`, `34f9d9d`, `60d3a4a` (indirectly via .gitignore touches).
- Cause: CI pipeline was iteratively debugged post-initial commit (DATABASE_URL for prisma generate, prisma generate per-job duplication, validate-bats-coverage job addition, auto-triage wiring).
- Observation: Churn reflects bootstrap iteration, not ongoing instability. Pattern may recur when Vercel and E2E jobs are activated.

**Files changed twice (secondary churn):**
- `scripts/ci/validate-commits.sh` — node setup removal then content fix
- `renovate.json` — initial commit then rangeStrategy scope fix
- `infra/github/main.tf` — initial commit then `lifecycle.ignore_changes` addition
- `commitlint.config.js` — CJS then ESM migration
- `.pre-commit-config.yaml` — bootstrap then bats-coverage hook addition
- `apps/web/package.json`, vitest configs — jsdom and passWithNoTests fixes

**Repository age note:** 16 commits spanning 2026-06-24 to 2026-06-28 (4 days). Churn rate is high relative to commit count but expected for a bootstrap build-out phase.

---

## Architectural Risks

**Template snapshot model has no consumer update path:**
- Risk: HIGH (by design, but must be understood by instantiators)
- Issue: `docs/adr/0001-snapshot-model.md` explicitly documents this: once `gh repo create --template` is used, changes to `tgh-template` do not propagate to consumer repos. There is no `git pull upstream` path.
- Impact: Governance improvements (CI scripts, ADR validator logic, Tofu IaC) must be manually ported to each instantiated project. Stale governance is the expected steady state for consumers.
- Fix approach: Document the manual sync procedure in CLAUDE.md or a dedicated UPGRADING.md in the template.

**Layer 2 entirely absent — first instantiation (MDE) will validate all assumptions:**
- Risk: HIGH
- Issue: The template has never been instantiated. All Layer 1 assumptions (NX module boundaries, Prisma singleton, CVA components, Zod env parsing) are untested end-to-end with real application code.
- Files: `apps/web/src/app/page.tsx` (stub), `packages/db/prisma/schema.prisma` (single User model stub), `packages/ui/src/components/` (stub button only)
- Impact: Integration friction will appear at first real use. ADR 0022 and 0017 (module boundary enforcement) have not been validated under real cross-package import patterns.

**ADR sequence gaps — 0009, 0014, 0019 missing:**
- Risk: LOW
- Issue: ADR directory contains 0001-0008, 0010-0013, 0015-0018, 0020-0023 but 0009, 0014, and 0019 do not exist.
- Files: `docs/adr/`
- Impact: Gap is silent — validate-adrs.sh validates existing files only, never checks for gaps. Gaps may reflect intentionally skipped numbers or lost draft ADRs.
- Fix approach: Add a `check-adr-sequence.sh` check or document that gaps are intentional placeholders.

**Duplicate ADR covering same topic (0011 vs 0022):**
- Risk: MEDIUM
- Issue: `docs/adr/0011-nx-module-boundary-tags.md` and `docs/adr/0022-nx-module-boundaries-tags.md` both address NX module boundary tag enforcement. Neither supersedes the other (no `supersedes:` frontmatter key).
- Files: `docs/adr/0011-nx-module-boundary-tags.md`, `docs/adr/0022-nx-module-boundaries-tags.md`
- Impact: Ambiguity about which ADR is authoritative. `validate-adrs.sh` does not detect duplicate topic coverage.
- Fix approach: Add `supersedes: 0011-nx-module-boundary-tags.md` to 0022, update 0011 status to `superseded`.

---

## Complexity Hotspots

**`scripts/ci/validate-adrs.sh` — awk-based frontmatter parser (134 lines):**
- Risk: MEDIUM
- Files: `scripts/ci/validate-adrs.sh:120-127`
- Issue: Frontmatter parsing is implemented in inline awk. The `read_frontmatter` function (lines 120-127) exits with error code 1 if frontmatter is missing or unclosed. The `frontmatter_value` function (lines 129-132) uses `sed` piped through a here-string. This combination is fragile for multi-line values or YAML arrays (tags field).
- Specific fragility: `check_required_keys` at line 64 uses `grep -q "^$key:"` — this will false-negative if the key appears mid-document after the frontmatter delimiter.
- Test coverage: `validate-adrs.bats` exists, partially covers this.

**`.github/workflows/1-commit.yml` — Prisma generate repeated 4 times in Phase 1:**
- Risk: LOW
- Files: `.github/workflows/1-commit.yml:107-110`, `:121-124`, `:135-138`, `:149-152`
- Issue: The `prisma generate` step with `DATABASE_URL: postgresql://localhost/dummy` is copy-pasted identically into `typecheck`, `lint`, `test`, and `build` jobs. No reusable workflow or composite action is used.
- Impact: Any change to the generate command (e.g., different dummy URL, added env var) must be made in four places.
- Fix approach: Extract a composite action at `.github/actions/prisma-generate/action.yml`.

**`infra/github/backend.tf` — requires manual intervention before any IaC operation:**
- Risk: HIGH
- Files: `infra/github/backend.tf:4`
- Issue: Literal string `"TODO-configure-your-gcs-bucket-name"` in the GCS backend config. Running `tofu init` without replacing this will configure a backend pointing at a non-existent bucket.
- Compounding risk: The Cloudflare R2 alternative backend is commented in lines 6-18, providing no active fallback.

**`apps/web-e2e/src/smoke.spec.ts` — hard-codes template name:**
- Risk: MEDIUM
- Files: `apps/web-e2e/src/smoke.spec.ts:1,6`
- Issue: The smoke test asserts `expect(page).toHaveTitle(/tgh-template/)` and `expect(page.getByRole('heading', { name: 'tgh-template' })).toBeVisible()`. These assertions reference the template's placeholder name.
- Impact: Every instantiated project inherits these tests. They will fail in production until the consumer renames their app — but they may pass in CI if the rename is not done and the page still shows the scaffold text, giving false confidence.
- Fix approach: Add instance-name substitution step to the instantiation checklist in CLAUDE.md.

---

## Missing Test Coverage

**`packages/domain` has no test files:**
- Risk: MEDIUM
- Files: `packages/domain/vitest.config.ts:7` (`passWithNoTests: true`)
- Issue: The domain package — intended to hold core business logic — has no tests. `passWithNoTests: true` ensures CI does not fail, but any logic added to this package starts untested.

**`packages/ui` has one stub button test; no component integration tests:**
- Risk: LOW
- Files: `packages/ui/src/components/button.test.tsx`
- Issue: UI package tests coverage is minimal. No tests for the CVA variant pattern that ADR 0003 (`docs/adr/0003-nextjs-vercel-prisma.md`) references.

**Zero E2E runs have ever completed against a real deployment:**
- Risk: HIGH
- Issue: `apps/web-e2e/src/smoke.spec.ts` exists but has never been executed against a live URL (`PLAYWRIGHT_BASE_URL` secret requires Vercel, which is not connected). The E2E test suite is entirely theoretical.

---

## Stale Documentation

**`DECISIONS.md` entry for CJS/ESM migration is outdated:**
- Risk: LOW
- Files: `DECISIONS.md:15`
- Issue: The single log entry states "Will migrate to ESM in Phase H when root package.json is committed." The root `package.json` now has `"type": "module"` (line 4) and `commitlint.config.js` already uses ESM (`export default`). The DECISIONS.md entry was not updated to reflect the completed migration.

**`docs/issues/` deleted without traceable issue links:**
- Risk: LOW
- Issue: Commit `34f9d9d` deleted `docs/issues/` with message "drafts converted to real GH issues." No issue numbers or URLs are recorded in the commit message or DECISIONS.md. The actual GitHub issues are not auditable from the repository.

---

## Dependencies at Risk

**`renovatebot/github-action@v46` — unpinned major version:**
- Risk: LOW
- Files: `.github/workflows/renovate.yml:21`
- Issue: Action is pinned to `@v46` (floating major tag), not a SHA. A breaking change in v46.x could silently alter Renovate behavior.

**`gitleaks/gitleaks-action@v2` and `raven-actions/actionlint@v2` — floating major tags:**
- Risk: LOW
- Files: `.github/workflows/1-commit.yml:25`, `:32`
- Issue: Security tooling actions pinned to major version tags rather than commit SHAs. Supply chain risk applies specifically to security scanning actions.
- Fix approach: Pin all third-party actions to full SHA digests per OSSF Scorecards recommendation.

---

*Concerns audit: 2026-06-28*
