# Architecture

**Analysis Date:** 2026-06-28

## Pattern Overview

**Overall:** Governance-first monorepo template with a three-layer composition model.

**Key Characteristics:**
- Stack-agnostic governance layer (Layer 0) is always present; technology overlay (Layer 1) is additive
- CI pipeline is the primary quality gate — no human review required for merge
- Template repository: consumed by clicking "Use this template", not by running generators
- All structural decisions are recorded as ADRs in `docs/adr/`

## Three-Layer Model

**Layer 0 — Governance (stack-agnostic):**
- Purpose: ADR enforcement, conventional commits, secret scanning, shell lint, CI gate structure, GitHub IaC
- Location: `scripts/ci/`, `.github/workflows/`, `infra/github/`, `docs/adr/`, `.pre-commit-config.yaml`
- Depends on: nothing (pure bash, BATS, shell)
- Used by: every instantiated project, regardless of tech stack

**Layer 1 — NX / Next.js / Vercel / Prisma overlay:**
- Purpose: Opinionated application scaffold for the nextjs-vercel-prisma stack
- Location: `apps/`, `packages/`, `nx.json`, `tsconfig.base.json`, `eslint.config.mjs`
- Depends on: Layer 0 (governance still applies)
- Used by: projects instantiated from this template that target the Layer 1 stack

**Layer 2 — Instance-specific application logic:**
- Purpose: The actual product built on top of Layers 0 and 1
- Location: Not present in this repository; added post-instantiation
- Depends on: Layers 0 and 1
- Used by: each individual project created from this template

## CI/CD Topology

**Workflow chain (strictly sequential via `workflow_run`):**

```
push → 1-commit.yml ──(success on main)──▶ 2-e2e.yml ──(success on main)──▶ 3-promote.yml
```

**`1-commit.yml` — Commit Validation:**
- Trigger: `push: branches: ['**']` and `pull_request`
- Gate: Phase 0 gates Phase 1 (see below)
- Sole required GitHub status check: `commit-validation` aggregate job
- On failure: `auto-triage.yml` creates a GitHub issue automatically

**`2-e2e.yml` — E2E:**
- Trigger: `workflow_run` on `"Commit Validation"` completed, branches `[main]`
- Guard: `github.event.workflow_run.conclusion == 'success'`
- Runs Playwright against `${{ secrets.VERCEL_PREVIEW_URL }}`
- Uploads Playwright report artifact on failure (7-day retention)

**`3-promote.yml` — Promote to Production:**
- Trigger: `workflow_run` on `"E2E"` completed, branches `[main]`; also `workflow_dispatch` with confirmation
- Jobs: `validate-input` (dispatch only) → `migrate` (runs `prisma migrate deploy` then `vercel promote`)
- Environments: `production` (uses `DATABASE_URL_PROD` and `VERCEL_TOKEN`)

**`infra.yml` — Infrastructure:**
- Trigger: `push` or `pull_request` touching `infra/**`
- PR: runs `tofu plan`, posts plan as PR comment
- Push to main: runs `tofu apply -auto-approve`

**`auto-triage.yml`:** Reusable `workflow_call` — creates a GitHub issue labeled `acceptance-failure`

**`incident.yml`:** DORA instrumentation for production incidents (label-triggered)

**`renovate.yml`:** Dependency update automation; requires `RENOVATE_TOKEN` secret

## Phase 0 / Phase 1 Gate Structure

**Phase 0 — Governance (all parallel, ~15–30s):**

| Job | Tool | Purpose |
|-----|------|---------|
| `gitleaks` | gitleaks-action@v2 | Secret scanning |
| `actionlint` | raven-actions/actionlint@v2 | Workflow YAML lint |
| `validate-adrs` | `scripts/ci/validate-adrs.sh` | ADR structure validation |
| `validate-commits` | `scripts/ci/validate-commits.sh` | Conventional commit format |
| `shellcheck` | `scripts/ci/run-shellcheck.sh` | Shell script lint |
| `validate-bats-coverage` | `scripts/ci/validate-bats-coverage.sh` | Every `.sh` has a `.bats` file |
| `prisma-migrate-check` | `prisma migrate deploy` | Schema validity against Postgres 17 |

**Phase 1 — Quality (gated by all Phase 0 jobs):**

| Job | Command |
|-----|---------|
| `typecheck` | `npx nx run-many -t typecheck` |
| `lint` | `npx nx run-many -t lint` |
| `test` | `npx nx run-many -t test` |
| `build` | `npx nx run-many -t build` |

Each Phase 1 job runs `npx prisma generate` with a dummy `DATABASE_URL` before NX tasks (Prisma types must exist for TypeScript compilation).

**Aggregate job:** `commit-validation` has `needs:` listing all Phase 0 and Phase 1 jobs, runs `if: always()`, and reads `$NEEDS_JSON` via `scripts/ci/validate-aggregate.sh`. Any non-`success` result (including `skipped`) causes failure. This is the sole required GitHub status check.

## NX Monorepo Workspace Layout

**Plugin inference (no `project.json` targets needed):**
- `@nx/next` — infers `build`, `dev`, `start` targets from `next.config.ts`
- `@nx/vite` — infers `test` target from `vitest.config.ts`
- `@nx/eslint` — infers `lint` target from `eslint.config.mjs`
- `@nx/playwright` — infers `e2e` target from `playwright.config.ts`

**Caching:** `build`, `test`, `lint`, `typecheck` all cached; `build` depends on `^build` (upstream packages build first)

**Module boundary enforcement (`eslint.config.mjs`):**

```
scope:web    → may import from scope:web, scope:domain, scope:shared
scope:domain → may import from scope:domain, scope:shared
scope:shared → may import from scope:shared only
```

Tags are declared in each project's `project.json`:
- `apps/web` → `scope:web`
- `apps/web-e2e` → `scope:web`
- `packages/ui` → `scope:shared`
- `packages/config` → `scope:shared`
- `packages/db` → `scope:shared`
- `packages/domain` → `scope:domain`

## Prisma Singleton Pattern

**File:** `packages/db/src/index.ts`

**Pattern:** `globalThis`-based singleton to survive Next.js hot-module replacement.

```typescript
const globalForPrisma = globalThis as unknown as { prisma: PrismaClient | undefined };

export const prisma =
  globalForPrisma.prisma ?? new PrismaClient({ log: [...] });

if (process.env.NODE_ENV !== 'production') globalForPrisma.prisma = prisma;
```

- Development: assigns to `globalThis` to prevent connection leaks on HMR
- Production: creates a new instance per Worker/Edge runtime (no global assignment)
- Schema: `packages/db/prisma/schema.prisma` — PostgreSQL, single `User` model as scaffold
- Config: `packages/db/prisma.config.ts` uses `defineConfig` with explicit schema path; all Prisma commands must pass `--config packages/db/prisma.config.ts`

## ADR Governance System

**Location:** `docs/adr/`

**Frontmatter schema (required for all ADRs except `0000-template.md` and `README.md`):**
```yaml
---
status: proposed | accepted | rejected | deprecated | superseded
date: YYYY-MM-DD
tags: [tag1, tag2]
implementation: path/to/file   # required when status=accepted AND tags include "tooling"
---
```

**Required sections:** `## Context`, `## Decision`, `## Consequences`

**Filename pattern:** `NNNN-kebab-case-title.md` (4-digit sequential, never date-based, never reused)

**Reserved numbers:** `0000` (template), `0001–0005` (template meta-ADRs, never modify in instances)

**Instance ADRs:** Start at `0100+`

**Validation:** `scripts/ci/validate-adrs.sh docs/adr` — runs in Phase 0 CI and as pre-commit hook. Validates: filename format, frontmatter presence, required keys, status enum, date format, `implementation` key for accepted tooling ADRs, `supersedes` reference existence.

## OpenTofu GitHub IaC Design

**Location:** `infra/github/`

**State backend:** GCS bucket (configured in `infra/github/backend.tf` — bucket name is a TODO placeholder until first apply)

**Provider:** `integrations/github ~> 6.0`

**Resources managed:**
- `github_repository.repo` — visibility, merge strategy (squash-only, `BLANK` message), auto-merge, template flag
- `github_repository_ruleset.main_protection` — branch protection on `~DEFAULT_BRANCH`: required linear history, deletion protection, `Commit Validation` status check required, 0 required reviewers, `strict = false`
- `github_repository_environment.production` and `.preview`
- `github_issue_label.labels` — 14 custom labels (see `main.tf`)

**Automation:** `infra.yml` runs `tofu plan` on PRs (posts comment), `tofu apply` on push to main

**Bootstrap blocker:** GCS bucket does not exist yet; `backend.tf` has `bucket = "TODO-configure-your-gcs-bucket-name"`. Tofu has never been applied.

## Branch Protection and Merge Strategy

**Enforced by:** `infra/github/main.tf` `github_repository_ruleset.main_protection` (pending Tofu apply)

**Rules:**
- Target: `~DEFAULT_BRANCH` (survives renames)
- Required linear history: yes (enforces squash merges)
- Deletion protection: yes
- Required status check: `"Commit Validation"` (the aggregate job name)
- `strict_required_status_checks_policy = false` — PRs need not be up-to-date with main
- Required approving reviews: 0 — automation is the sole gate
- Auto-merge: enabled on repository (`allow_auto_merge = true`)
- Merge commit: disabled; rebase merge: disabled — squash-only
- `squash_merge_commit_message = "BLANK"` — commit message is blank, not PR body
- `delete_branch_on_merge = true`

## Error Handling

**CI failures:**
- Phase 0 failure → Phase 1 does not run; `commit-validation` fails; `auto-triage.yml` creates a GitHub issue
- `validate-aggregate.sh` treats any non-`success` job result (including `skipped`) as failure

**Application:**
- `packages/config/src/index.ts`: `parseEnv()` throws with structured field errors on invalid env vars (Zod `safeParse`)
- No application-level error boundary in scaffold (`apps/web/src/app/` has only `layout.tsx` and `page.tsx`)

## Cross-Cutting Concerns

**Conventional commits:** Enforced at `commit-msg` hook (`commitlint`) and in Phase 0 CI (`validate-commits.sh`). Config: `commitlint.config.js` (extends `@commitlint/config-conventional`). Header ≤ 72 chars.

**Secret scanning:** Gitleaks in Phase 0; `.gitleaks.toml` configures allowlist

**BATS coverage:** Every `scripts/ci/*.sh` must have a corresponding `scripts/ci/*.bats` — enforced by `validate-bats-coverage.sh` in Phase 0

**Environment validation:** `@template/config` exports `parseEnv()` — validates `NODE_ENV` and `DATABASE_URL` using Zod at startup

**Dependency updates:** Renovate via `renovate.json`; requires `RENOVATE_TOKEN` secret (not yet configured)

---

*Architecture analysis: 2026-06-28*
