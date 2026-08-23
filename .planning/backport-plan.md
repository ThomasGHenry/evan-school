# tgh-template Backport Plan

Derived from cross-project comparison (BLM, diane-v01, MDE) — 2026-07-07.
Source repos: `~/code/business-learning-machine/`, `~/code/diane-v01/`, `~/code/mde/`.

## Summary of work

~15 new files (copy/create), ~11 existing file edits.

**Heaviest single task**: pnpm migration (Phase 2) — touches every `package.json` + 3 CI YAMLs.
Everything else is additive.

**Do not start Phase 3+ until Phase 2 (pnpm) is done** — CI YAMLs must reference pnpm, not npm.

---

## Phase 1 — New files only (zero edits to existing)

These can be done in any order, in isolation. Pure cp/create.

### 1.1 Agent entry point

- [x] Create `AGENTS.md` — canonical agent entry for multi-model world. Copy from BLM (`~/code/business-learning-machine/AGENTS.md`), strip BLM-specific agent list, keep template-generic instructions.
- [x] Create `GEMINI.md` as symlink: `ln -s CLAUDE.md GEMINI.md`

### 1.2 Speckit scaffold

`.specify/memory/constitution.md` **already exists** (commit `34f9d9d`) — comprehensive stub covering governance philosophy, module boundaries, testing strategy, 16 non-negotiables. Do not recreate.

Note: constitution currently lists `npm workspaces` as package manager — **update this in Phase 2** alongside the actual pnpm migration.

Remaining items:

- [x] ~~Create `.specify/memory/constitution.md`~~ — already done (commit `34f9d9d`)
- [x] Create `.specify/memory/north-star.md` stub:
  ```markdown
  # North Star

  > Replace this file with your project's north star after instantiation.
  ```
- [x] Create `.specify/specs/` directory (empty — instances populate via speckit workflow)
- [x] Copy `extensions.yml` from diane-v01 (`.specify/extensions.yml`), remove diane-specific before/after hook commands, leave structure intact.

### 1.3 Coverage ratcheting scaffold

- [x] Create `coverage_floor.json` at repo root: `{}` — instances populate as tests are written.
- [x] Copy ratchet script from diane-v01: `cp ~/code/diane-v01/scripts/ci/ratchet-coverage.sh scripts/ci/ratchet-coverage.sh`
- [x] Create BATS sibling: `scripts/ci/ratchet-coverage.bats` (required by `validate-bats-coverage.sh` — every .sh needs a .bats)
- [x] Copy coverage gate script if diane has one (check `~/code/diane-v01/scripts/ci/coverage-gate.sh`) — diane did not have a separate script; coverage gate implemented inline in CI `coverage-gate` job.

### 1.4 Pre-push hook script

- [x] Copy from MDE: `cp ~/code/mde/scripts/hooks/pre-push.sh scripts/hooks/pre-push.sh`
  - Hook validates full push commit range with `validate-commits.sh`
  - If `scripts/hooks/` dir doesn't exist: `mkdir -p scripts/hooks/`
- [x] Update `scripts/setup-hooks.sh` to install the pre-push hook if not already handled. — already installed via `pre-commit install --hook-type pre-push`

### 1.5 Vercel deployment resolver

- [x] Copy from BLM: `cp ~/code/business-learning-machine/scripts/ci/resolve-vercel-deployment.sh scripts/ci/resolve-vercel-deployment.sh`
  - Resolves Vercel build URL by git SHA — prevents race condition where CI grabs wrong deploy
- [x] Create BATS sibling: `scripts/ci/resolve-vercel-deployment.bats`

### 1.6 Auto-merge workflow

- [x] Copy from BLM: `cp ~/code/business-learning-machine/.github/workflows/auto-merge.yml .github/workflows/auto-merge.yml`
  - Verify secret names match tgh-template conventions (`GITHUB_APP_ID`, `GITHUB_APP_PRIVATE_KEY`)
  - Remove BLM-specific conditions if any

### 1.7 CodeRabbit config

- [x] Create `.coderabbit.yaml` at repo root — copy from BLM or diane, review for project-agnostic settings.
- [x] Scope to review-on-push only (not PR description generation — that's project-specific).

### 1.8 Design token scaffold

- [x] Create `packages/ui/src/tokens/` directory.
- [x] Copy `base.ts` from BLM (`~/code/business-learning-machine/packages/ui/src/tokens/base.ts`):
  - Strip all "Black Lodge" branding references
  - Keep OKLCH structure and slot names (background, foreground, primary, etc.)
  - Rename to generic slot names if needed
- [x] Copy `contrast.test.ts` from BLM:
  - Validates WCAG AA contrast ratios — framework-agnostic
  - Update imports to reference local `base.ts`
- [x] Export tokens from `packages/ui/src/index.ts`

### 1.9 Infra restructure (new modules only)

- [x] Create `infra/bootstrap/` — GitHub App creation + R2 bucket setup (one-time manual bootstrap).
  Copy structure from BLM `infra/bootstrap/`. This module is run once before `infra/github/`.
- [x] Create `infra/platform/` — Vercel project, environments, env vars.
  Copy structure from BLM `infra/platform/`. Replaces manual Vercel setup steps in CLAUDE.md bootstrap section.
- [x] Update `CLAUDE.md` bootstrap section to reflect 3-module IaC order: bootstrap → github → platform.

### 1.11 GitHub community files

**Mostly already done** (commit `3853d56`). Remaining gaps only.

Already present:
- [x] ~~`bug-needs-triage.yml`~~ — exists
- [x] ~~`bug-triaged.yml`~~ — exists
- [x] ~~`feature.yml`~~ — exists
- [x] ~~`tooling.yml`~~ — exists
- [x] ~~`config.yml`~~ — exists (`blank_issues_enabled: false`)
- [x] ~~`pull_request_template.md`~~ — exists (needs `pnpm exec nx` update in Phase 2)

Remaining:

- [x] Create `epic.yml` from diane-v01, stripping diane-specific content. Keep:
  - `goal` textarea (outcome-framed, one sentence)
  - `success_criterion` textarea (measurable signal epic is done)
  - `child_issues` textarea
  - `out_of_scope` textarea
  - `dependencies` textarea
  - Remove: `north_star` alignment (diane-specific), `phase` dropdown (v0.1/v0.2 phases)
  - Labels: `epic`
- [x] Add `contact_links` to existing `config.yml`:
  ```yaml
  contact_links:
    - name: Project PRD
      url: https://github.com/ThomasGHenry/tgh-template/blob/main/PRD.md
      about: Purpose, architecture, and acceptance criteria
    - name: CLAUDE.md
      url: https://github.com/ThomasGHenry/tgh-template/blob/main/CLAUDE.md
      about: Development conventions and bootstrap guide
  ```
  *(Instances replace these URLs after instantiation)*
- [x] Copy `.github/LABEL_TAXONOMY.md` from BLM/MDE (identical, template-generic). Labels provisioned by Tofu — this is reference only.

### 1.10 Clerk auth stub

- [x] Create `apps/web/src/middleware.ts` — minimal stub:
  ```typescript
  export { default } from './middleware.stub'
  ```
  Or a commented stub showing where Clerk middleware wires in.
  Source: BLM `apps/web/src/middleware.ts` — strip Clerk-specific config, leave structure.
- [x] Create ADR: `docs/adr/0024-clerk-as-default-auth.md` — documents that template ships Clerk-ready middleware stub; instances swap auth provider by replacing middleware.ts.

---

## Phase 2 — pnpm migration (most invasive, do first among edits)

**Do this as one atomic commit. BLM did this at commit `6b325d6` — reference it.**

### 2.1 Workspace config

- [x] Delete `package-lock.json`
- [x] Create `pnpm-workspace.yaml`:
  ```yaml
  packages:
    - 'apps/*'
    - 'packages/*'
  ```
- [x] Create `.npmrc`:
  ```
  shamefully-hoist=true
  ```
  (Required for NX module resolution with pnpm)

### 2.2 Root package.json

- [x] Remove `"workspaces"` field (pnpm uses `pnpm-workspace.yaml` instead)
- [x] Update any npm scripts that use `npm run` → `pnpm run` where needed
- [x] Verify `"packageManager"` field set to `"pnpm@10.28.1"` (or current version)

### 2.3 Per-package package.json files

- [x] `apps/web/package.json` — no workspace protocol changes needed (pnpm auto-converts)
- [x] `apps/web-e2e/package.json` — same
- [x] `packages/config/package.json` — same
- [x] `packages/db/package.json` — same
- [x] `packages/domain/package.json` — same
- [x] `packages/ui/package.json` — same

### 2.4 Generate lockfile

- [x] Run `fnm use 22 && pnpm install` — generates `pnpm-lock.yaml`
- [x] Verify NX still resolves: `pnpm exec nx run-many -t typecheck`

### 2.5 CI YAML — pnpm setup (all 3 workflows)

- [x] `.github/workflows/1-commit.yml` — replace `npm ci` steps:
  ```yaml
  - uses: pnpm/action-setup@v4
    with:
      version: 10
  - uses: actions/setup-node@v4
    with:
      node-version: 22
      cache: 'pnpm'
  - run: pnpm install --frozen-lockfile
  ```
- [x] `.github/workflows/2-e2e.yml` — same pnpm setup pattern
- [x] `.github/workflows/3-promote.yml` — same pnpm setup pattern
- [x] Replace any remaining `npm run` → `pnpm run` in CI steps

---

## Phase 3 — CI YAML edits (after Phase 2)

### 3.0 Path-based change detection ("pathfinder")

**Runs as the first Phase 0 job — all compute Phase 1 jobs gate on its outputs.**

Pattern: `dorny/paths-filter@v3` emits per-path boolean outputs consumed by downstream jobs
via `if: needs.changes.outputs.<filter> == 'true'`. Saves full Phase 1 cost on doc-only or
infra-only commits.

- [x] `.github/workflows/1-commit.yml` — add `changes` job at top of Phase 0:
  ```yaml
  changes:
    runs-on: ubuntu-latest
    outputs:
      web: ${{ steps.filter.outputs.web }}
      packages: ${{ steps.filter.outputs.packages }}
      db: ${{ steps.filter.outputs.db }}
      infra: ${{ steps.filter.outputs.infra }}
      scripts: ${{ steps.filter.outputs.scripts }}
      docs: ${{ steps.filter.outputs.docs }}
      ci: ${{ steps.filter.outputs.ci }}
    steps:
      - uses: actions/checkout@v4
      - uses: dorny/paths-filter@v3
        id: filter
        with:
          filters: |
            web:
              - 'apps/web/**'
              - 'apps/web-e2e/**'
            packages:
              - 'packages/**'
            db:
              - 'packages/db/**'
            infra:
              - 'infra/**'
            scripts:
              - 'scripts/**'
            docs:
              - 'docs/**'
            ci:
              - '.github/workflows/**'
  ```
- [x] Gate Phase 1 compute jobs on relevant filters:
  - `typecheck`: `needs.changes.outputs.web == 'true' || needs.changes.outputs.packages == 'true'`
  - `lint`: same as typecheck
  - `test`: same as typecheck
  - `build`: same as typecheck
  - `prisma-migrate-check`: `needs.changes.outputs.db == 'true'`
  - `infra` (tofu plan): `needs.changes.outputs.infra == 'true'`
  - Phase 0 governance jobs (`validate-adrs`, `shellcheck`, `validate-bats-coverage`): add `needs: [changes]` but **no path gate** — governance always runs.
- [x] `commit-validation` aggregate: must still `needs:` all gated jobs. Use `if: always()` on the aggregate so it passes even when upstream jobs were skipped (not failed).
- [x] **Important**: on `push` to `main` (not PR), always run all jobs regardless of path filter — avoids skipping on squash merges where diff is empty. Add:
  ```yaml
  if: needs.changes.outputs.web == 'true' || github.event_name == 'push'
  ```
- [ ] Add `dorny/paths-filter` to `renovate.json` or `renovate.yml` dep groups so it gets version bumps. — **N/A: this template has no renovate config; instances add it.**
- [x] Reference diane-v01 `changes` job implementation for exact YAML structure.

### 3.1 Concurrency groups

- [x] `.github/workflows/1-commit.yml` — add at top level:
  ```yaml
  concurrency:
    group: ${{ github.workflow }}-${{ github.ref }}
    cancel-in-progress: true
  ```
- [x] `.github/workflows/2-e2e.yml` — same (cancel-in-progress: true — E2E on stale commit is waste)
- [x] `.github/workflows/3-promote.yml` — add concurrency group but `cancel-in-progress: false` (never cancel mid-promote)

### 3.2 pnpm store cache (Phase 0 speed)

- [x] `.github/workflows/1-commit.yml` — `actions/setup-node@v4` with `cache: 'pnpm'` already handles pnpm store caching; separate `actions/cache` step is redundant. No additional step needed.

### 3.3 Phase 2 — E2E smoke on PRs

- [ ] `.github/workflows/1-commit.yml` — add Phase 2 jobs gated on Phase 1:
  - Trigger Vercel preview build
  - Wait for Vercel deployment (use `resolve-vercel-deployment.sh` from 1.5)
  - Run `pnpm exec playwright test --grep @smoke` against preview URL
- [ ] Reference BLM / MDE E2E-on-PR pattern for exact job structure

**Note: deferred. `2-e2e.yml` handles full E2E post-commit. In-pipeline smoke requires Vercel Preview URLs per PR — needs Vercel project configured first (bootstrap step).**

### 3.4 validate_spec_kit job (Phase 0)

- [x] `.github/workflows/1-commit.yml` — add Phase 0 job:
  ```yaml
  validate-speckit:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Validate spec structure
        run: bash scripts/ci/validate-speckit.sh
  ```
- [x] Create `scripts/ci/validate-speckit.sh` — validates `.specify/` structure exists (not content) and `extensions.yml` is valid YAML.
- [x] Create `scripts/ci/validate-speckit.bats` — BATS sibling.
- [x] Add `validate-speckit` to `commit-validation` `needs:` array.

### 3.5 Coverage gate job (Phase 1, after test)

- [x] `.github/workflows/1-commit.yml` — add coverage gate job after test job:
  ```yaml
  coverage-gate:
    needs: [test]
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: bash scripts/ci/ratchet-coverage.sh
  ```
- [x] Add `coverage-gate` to `commit-validation` `needs:` array.

---

## Phase 4 — Hook and lint config edits

### 4.1 Pre-push hook registration

- [x] `.pre-commit-config.yaml` — add `pre-push` stage to `default_stages` or add hook entry:
  ```yaml
  - id: pre-push-validate
    name: Commit Range Validation
    language: system
    entry: bash scripts/hooks/pre-push.sh
    stages: [pre-push]
    pass_filenames: false
  ```

### 4.2 CodeRabbit pre-push hook

- [ ] `.pre-commit-config.yaml` — add CodeRabbit hook at `pre-push` stage:
  ```yaml
  - id: coderabbit-review
    name: CodeRabbit Review
    language: system
    entry: bash scripts/hooks/coderabbit-review.sh
    stages: [pre-push]
    pass_filenames: false
  ```
- [ ] Create `scripts/hooks/coderabbit-review.sh` — copy from diane or write minimal version that calls CodeRabbit CLI.
- [ ] Note: CodeRabbit CLI requires subscription + API key in env. Hook should fail gracefully if `CODERABBIT_API_KEY` not set (warn, don't block).

**Note: deferred. CodeRabbit CLI hit free-tier limit during review session; org not connected. Implement when org account is set up.**

### 4.3 no-restricted-imports for domain purity

- [x] `eslint.config.mjs` — add rule to `scope:domain` config block:
  ```js
  'no-restricted-imports': ['error', {
    patterns: [{
      group: ['@prisma/client', '@template/db'],
      message: 'Domain must not import database concerns directly.'
    }]
  }]
  ```
  (Update `@template/db` → `@<project>/db` if namespace renamed)

---

## Phase 5 — ADR governance edits

### 5.1 Bidirectional supersession validation

- [x] `scripts/ci/validate-adrs.sh` — add check: if ADR has `supersedes: <slug>`, verify that `<slug>.md` has `status: superseded` (or `superseded_by:` field). Fail if mismatch.
- [x] `scripts/ci/validate-adrs.bats` — add test cases for bidirectional check.

### 5.2 ADR template optional sections

- [x] `docs/adr/0000-template.md` — add optional sections after `## Consequences`:
  ```markdown
  ## Hypothesis *(optional — fill before implementation)*

  What we expect to happen, and what we'll measure to know we were right.

  ## Findings *(optional — fill post-implementation)*

  What actually happened. Link to PR, metrics, or incidents.
  ```

### 5.3 New ADR for Clerk

- [x] `docs/adr/0024-clerk-as-default-auth.md` — document template ships Clerk-ready stub;
  instances configure or replace. Status: `accepted`.

### 5.4 New ADR for pnpm

- [x] `docs/adr/0025-pnpm-workspace.md` — document pnpm migration, `shamefully-hoist`, NX compatibility.
  Status: `accepted`.

### 5.5 New ADR for R2 state backend

- [x] `docs/adr/0026-r2-terraform-state.md` — document switch from GCS placeholder to Cloudflare R2.
  Status: `accepted`. Reference BLM ADR-0105.

### 5.6 New ADR for GitHub App credential

- [x] `docs/adr/0027-github-app-terraform-credential.md` — document GitHub App over PAT for Tofu.
  Status: `accepted`. Reference BLM ADR-0111.

### 5.7 New ADR for path-based change detection

- [x] `docs/adr/0028-path-based-change-detection.md` — document `dorny/paths-filter`, per-job filter conditions, `if: always()` on aggregate, main-branch bypass to handle empty squash-merge diffs.
  Status: `accepted`.

### 5.8 New ADR for coverage ratcheting

- [x] `docs/adr/0029-coverage-ratcheting.md` — document `coverage_floor.json`, exit-code-2 auto-commit pattern from diane-v01, CI gate placement (Phase 1 after test), floor initialised at `{}` in template.
  Status: `accepted`. Reference diane-v01 pattern.

---

## Phase 6 — Infra edits (existing infra/github/)

### 6.1 R2 state backend

- [x] `infra/github/backend.tf` — replace GCS backend stub with Cloudflare R2:
  ```hcl
  terraform {
    backend "s3" {
      bucket                      = "tgh-template-tfstate"
      key                         = "github/terraform.tfstate"
      region                      = "auto"
      endpoint                    = "https://<account_id>.r2.cloudflarestorage.com"
      skip_credentials_validation = true
      skip_metadata_api_check     = true
      skip_region_validation      = true
      force_path_style            = true
    }
  }
  ```
- [x] Update `CLAUDE.md` bootstrap section — replace "Create GCS bucket" with "Create R2 bucket via Cloudflare dashboard."
- [x] Update `docs/github/secrets.md` — replace `GOOGLE_CREDENTIALS` with `CF_R2_ACCESS_KEY_ID`, `CF_R2_SECRET_ACCESS_KEY`.

### 6.2 GitHub App credential for Tofu

- [x] `infra/github/main.tf` — add `prevent_destroy = true` lifecycle on credential resources (ADR-0114 pattern).
- [x] `infra.yml` GHA workflow — replace PAT-based auth with GitHub App token exchange:
  - Add `actions/create-github-app-token@v1` step before Tofu commands
  - Inject `GITHUB_TOKEN` from App token
- [x] `docs/github/secrets.md` — add `GITHUB_APP_ID` + `GITHUB_APP_PRIVATE_KEY` secrets.

---

## Commit strategy

Each phase = one commit (or one commit per logical section within phase).

Suggested sequence:
1.  `chore: add agent entry point and speckit scaffold` (Phase 1.1–1.2) ✅ `42fa7bd`
2.  `chore: add coverage ratcheting scaffold` (Phase 1.3) ✅ `61aaf73`
3.  `chore: add pre-push hook and vercel deployment resolver` (Phase 1.4–1.5) ✅ `b29d31d` + `30e0568`
4.  `chore: add auto-merge workflow and coderabbit config` (Phase 1.6–1.7) ✅ `26fc145` + `0a64863`
5.  `feat: add design token scaffold with WCAG AA validation` (Phase 1.8) ✅ `238cb1f`
6.  `chore: restructure infra into bootstrap/github/platform modules` (Phase 1.9) ✅ `cd0310b`
7.  `chore: add epic issue template, label taxonomy, and config contact links` (Phase 1.11 remaining) ✅ `42fa7bd`
8.  `feat: add clerk auth middleware stub` (Phase 1.10) ✅ `4d17403`
9.  `chore: migrate npm to pnpm workspace` (Phase 2 — all at once, updates PR template + constitution) ✅ `f2f79c1`
10. `chore: add path-based change detection to CI` (Phase 3.0 — do before other CI edits) ✅ `dc81622`
11. `chore: add concurrency groups and pnpm cache to CI` (Phase 3.1–3.2) ✅ `dc81622`
12. `feat: add phase 2 E2E smoke on PRs` (Phase 3.3) — **deferred**
13. `feat: add speckit and coverage gate CI jobs` (Phase 3.4–3.5) ✅ `d1db9aa` + `dc81622`
14. `chore: add pre-push and coderabbit hooks` (Phase 4.1–4.2) ✅ `1ae7053` (4.2 deferred)
15. `chore: enforce domain purity via no-restricted-imports` (Phase 4.3) ✅ `1ae7053`
16. `chore: add bidirectional ADR supersession validation` (Phase 5.1) ✅ `38a0bba`
17. `docs: extend ADR template with hypothesis and findings sections` (Phase 5.2) ✅ `38a0bba`
18. `docs: add ADRs 0024-0029` (Phase 5.3–5.8) ✅ `38a0bba`
19. `chore: migrate infra state to R2 and add GitHub App credential` (Phase 6) ✅ `2c00cf4`

Post-plan review commit: `e05a28c` (CodeRabbit findings — critical/high/medium/low)

**Remaining open items:**
- Phase 3.3: E2E smoke in `1-commit.yml` — needs Vercel project bootstrap first
- Phase 4.2: CodeRabbit pre-push hook — needs org account + API key

---

## Source file reference

| Need | Source location |
|---|---|
| `AGENTS.md` | `~/code/business-learning-machine/AGENTS.md` |
| `auto-merge.yml` | `~/code/business-learning-machine/.github/workflows/auto-merge.yml` |
| `resolve-vercel-deployment.sh` | `~/code/business-learning-machine/scripts/ci/resolve-vercel-deployment.sh` |
| `packages/ui/src/tokens/base.ts` | `~/code/business-learning-machine/packages/ui/src/tokens/base.ts` |
| `packages/ui/src/tokens/contrast.test.ts` | `~/code/business-learning-machine/packages/ui/src/tokens/contrast.test.ts` |
| `infra/bootstrap/` | `~/code/business-learning-machine/infra/bootstrap/` |
| `infra/platform/` | `~/code/business-learning-machine/infra/platform/` |
| `apps/web/src/middleware.ts` (stub) | `~/code/business-learning-machine/apps/web/src/middleware.ts` |
| `pnpm migration pattern` | `~/code/business-learning-machine/` (commit `6b325d6`) |
| `ratchet-coverage.sh` | `~/code/diane-v01/scripts/ci/ratchet-coverage.sh` |
| `.specify/extensions.yml` | `~/code/diane-v01/.specify/extensions.yml` |
| `pre-push.sh` | `~/code/mde/scripts/hooks/pre-push.sh` |
| `coderabbit-review.sh` | `~/code/diane-v01/scripts/hooks/coderabbit-review.sh` |
| `.coderabbit.yaml` | `~/code/diane-v01/.coderabbit.yaml` or `~/code/business-learning-machine/.coderabbit.yaml` |
| R2 backend pattern | `~/code/business-learning-machine/infra/github/backend.tf` (BLM ADR-0105) |
| GitHub App Tofu pattern | `~/code/business-learning-machine/infra/github/` (BLM ADR-0111/0114) |
| E2E on PR pattern | `~/code/mde/.github/workflows/1-commit.yml` Phase 2 jobs |
| `changes` job / path filter | `~/code/diane-v01/.github/workflows/` (look for `dorny/paths-filter` usage) |
