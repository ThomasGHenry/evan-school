# External Integrations

**Analysis Date:** 2026-06-28

## Deployment Platform

**Vercel:**
- Purpose: Hosts the Next.js web app; preview deployments and production promotion
- Used in: `.github/workflows/2-e2e.yml`, `.github/workflows/3-promote.yml`
- CLI command: `npx vercel promote ${{ secrets.VERCEL_PREVIEW_URL }} --token ${{ secrets.VERCEL_TOKEN }}`
- Required secrets:
  - `VERCEL_TOKEN` — API token for Vercel CLI
  - `VERCEL_PREVIEW_URL` — URL of the preview deployment to promote and to run E2E against
- Status: Not yet configured (bootstrap gap — see `CLAUDE.md`)

## Data Storage

**PostgreSQL:**
- ORM: Prisma `^7.0.0` (`packages/db/`)
- Schema: `packages/db/prisma/schema.prisma` (provider: `postgresql`)
- Config: `packages/db/prisma.config.ts` (uses `prisma/config` `defineConfig`)
- Migrations: Prisma migrate (`migrate dev` for local, `migrate deploy` for production)
- CI uses ephemeral `postgres:17-alpine` service container in `prisma-migrate-check` job
- Connection env vars:
  - `DATABASE_URL` — development/CI connection string
  - `DATABASE_URL_PROD` — production connection string (used in `3-promote.yml`)
- Seed script: `packages/db/prisma/seed.ts` (run via `npm run db:seed` → `tsx`)

**File Storage:**
- Not integrated; local filesystem only in this template

**Caching:**
- NX local computation cache (`.nx/cache/`) — no remote cache configured

## Source Control & Repository Management

**GitHub:**
- Repository: `ThomasGHenry/tgh-template`
- `GITHUB_TOKEN` — built-in Actions token used for issue creation (`auto-triage.yml`), PR comments (`infra.yml`), deployment tracking (`3-promote.yml`, `incident.yml`)
- Branch protection ruleset managed via OpenTofu (`infra/github/main.tf`)
  - Required status check: `Commit Validation` (the `commit-validation` aggregate job)
  - Linear history enforced
  - No required approving reviews

**GitHub Environments:**
- `preview` — used by `2-e2e.yml` E2E job; gates `VERCEL_PREVIEW_URL`
- `production` — used by `3-promote.yml` migrate+promote job; gates `DATABASE_URL_PROD`
- `incident` — used by `incident.yml` for DORA MTTR tracking via `bobheadxi/deployments@v1`
- All three environments declared in `infra/github/main.tf` (applied via OpenTofu)

## CI/CD — GitHub Actions

**Runner:** `ubuntu-24.04` (all jobs)

**Workflow files:**
- `.github/workflows/1-commit.yml` — Phase 0 governance + Phase 1 quality gates; sole required check
- `.github/workflows/2-e2e.yml` — Playwright E2E against preview deployment; triggered on `main` after `1-commit.yml` succeeds
- `.github/workflows/3-promote.yml` — Prisma production migration + Vercel promotion; triggered after `2-e2e.yml` succeeds or via `workflow_dispatch`
- `.github/workflows/auto-triage.yml` — Creates GitHub issues on CI failure; called as reusable workflow from `1-commit.yml`
- `.github/workflows/infra.yml` — OpenTofu plan (on PR) and apply (on push to `main`) for `infra/github/`
- `.github/workflows/renovate.yml` — Dependency update bot; runs weekdays at 09:00 UTC
- `.github/workflows/incident.yml` — DORA incident tracking; triggered on issue label/close events

**Third-party GitHub Actions used:**

| Action | Version | Purpose | Workflow |
|--------|---------|---------|---------|
| `actions/checkout` | `v4` | Repo checkout | all workflows |
| `actions/setup-node` | `v4` | Node.js 22 + npm cache | `1-commit.yml`, `2-e2e.yml`, `3-promote.yml` |
| `actions/upload-artifact` | `v4` | Upload Playwright report on failure | `2-e2e.yml` |
| `gitleaks/gitleaks-action` | `v2` | Secret scanning | `1-commit.yml` |
| `raven-actions/actionlint` | `v2` | GitHub Actions workflow linting | `1-commit.yml` |
| `renovatebot/github-action` | `v46` | Dependency update bot | `renovate.yml` |
| `opentofu/setup-opentofu` | `v1` (tofu `1.9.0`) | OpenTofu IaC runner | `infra.yml` |
| `bobheadxi/deployments` | `v1` | Deployment environment tracking (DORA) | `3-promote.yml`, `incident.yml` |

## Secret Scanning

**Gitleaks:**
- Tool: `gitleaks/gitleaks-action@v2`
- Pre-commit: `scripts/ci/run-gitleaks.sh staged` via `.pre-commit-config.yaml`
- CI: runs as `gitleaks` job in Phase 0 of `1-commit.yml` with full history (`fetch-depth: 0`)
- Auth: `GITHUB_TOKEN` passed as env var to action

## Dependency Updates

**Renovate:**
- Action: `renovatebot/github-action@v46`
- Schedule: Monday–Friday, 09:00 UTC (`0 9 * * 1-5`)
- Required secret: `RENOVATE_TOKEN` (fine-grained PAT)
- Gated by `scripts/ci/check-renovate-token.sh` — skips gracefully if token absent

## Infrastructure as Code

**OpenTofu (Terraform-compatible):**
- Version: `>=1.6` (provider `integrations/github ~> 6.0`)
- Location: `infra/github/`
- Backend: GCS (`backend "gcs"`) — bucket name not yet configured (`infra/github/backend.tf`)
- Alternative backend documented: Cloudflare R2 (commented out in `infra/github/backend.tf`)
- Manages:
  - GitHub repository settings (`github_repository.repo`)
  - Branch protection ruleset (`github_repository_ruleset.main_protection`)
  - GitHub Environments: `production`, `preview`
  - 14 GitHub issue labels (`github_issue_label.labels`)
- Required secret: `TF_VAR_github_token` (fine-grained PAT with repo admin scope)
- CI: plan on PR, apply on push to `main` (`infra.yml`)
- Status: Not yet applied (bootstrap gap — see `CLAUDE.md`)

## Static Analysis Tools (CI-integrated)

**Actionlint:**
- Tool: `raven-actions/actionlint@v2`
- Pre-commit: `scripts/ci/run-actionlint.sh` for files matching `^\.github/workflows/.*\.yml$`
- CI: Phase 0 `actionlint` job in `1-commit.yml`

**ShellCheck:**
- Pre-commit: `scripts/ci/run-shellcheck.sh` for `*.sh` files
- CI: Phase 0 `shellcheck` job in `1-commit.yml`

## Auto-Triage / Issue Creation

**GitHub Issues API:**
- Script: `.github/scripts/auto-triage/create-issue.sh`
- Triggered: via `auto-triage.yml` reusable workflow when `commit-validation` fails
- Uses `GITHUB_TOKEN` + `gh` CLI to create or update a failure issue
- Labels applied: `acceptance-failure` (defined in OpenTofu labels)

## Incident Tracking (DORA)

**`bobheadxi/deployments@v1`:**
- Records deployment start when issue labeled `incident`
- Records resolution (MTTR computed in bash) when incident issue is closed
- Environment: `incident` (GitHub Deployments API)

## Authentication & Identity

- No auth provider integrated at the template level
- Auth is Layer 2 concern — instances add their own provider on top

## Monitoring & Observability

**Error Tracking:** Not integrated at template level

**Logs:** GitHub Actions native logs only

**DORA Metrics:** Incident MTTR tracked via `incident.yml` + `bobheadxi/deployments@v1`

## Environment Configuration

**Required env vars (runtime):**
- `DATABASE_URL` — PostgreSQL connection string (`packages/config/src/index.ts` validates via Zod)
- `NODE_ENV` — `development` | `test` | `production` (defaults to `development`)

**Required repository secrets (GitHub Actions):**
- `VERCEL_TOKEN` — Vercel CLI auth
- `VERCEL_PREVIEW_URL` — Preview deployment URL
- `DATABASE_URL_PROD` — Production PostgreSQL connection string
- `RENOVATE_TOKEN` — Fine-grained PAT for Renovate bot
- `TF_VAR_github_token` — Fine-grained PAT for OpenTofu GitHub provider

## Webhooks & Callbacks

**Incoming:**
- GitHub webhook to `incident.yml` on issue `labeled`/`closed` events (handled natively by GitHub Actions event triggers)

**Outgoing:**
- None defined at template level

---

*Integration audit: 2026-06-28*
