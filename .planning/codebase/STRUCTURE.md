# Codebase Structure

**Analysis Date:** 2026-06-28

## Directory Layout

```
tgh-template/
├── .github/                        # GitHub-managed files
│   ├── ISSUE_TEMPLATE/             # Issue form templates (bug, feature, tooling)
│   ├── scripts/auto-triage/        # Script called by auto-triage.yml
│   ├── workflows/                  # CI/CD workflow definitions
│   │   ├── 1-commit.yml            # Primary gate: Phase 0 + Phase 1 + aggregate
│   │   ├── 2-e2e.yml               # Playwright E2E (triggered by 1-commit success)
│   │   ├── 3-promote.yml           # Production promotion (triggered by 2-e2e success)
│   │   ├── auto-triage.yml         # Reusable: create issue on CI failure
│   │   ├── incident.yml            # DORA incident instrumentation
│   │   ├── infra.yml               # OpenTofu plan/apply for infra/github/
│   │   └── renovate.yml            # Dependency update automation
│   ├── LABEL_TAXONOMY.md           # Documentation of 14 custom GitHub labels
│   └── pull_request_template.md    # PR description template
├── .planning/codebase/             # GSD codebase map documents (this directory)
├── .specify/memory/
│   └── constitution.md             # Project governance philosophy and non-negotiables
├── apps/
│   ├── web/                        # Next.js 15 application (@template/web)
│   │   ├── src/app/                # Next.js App Router root
│   │   │   ├── layout.tsx          # Root layout
│   │   │   └── page.tsx            # Home page scaffold
│   │   ├── next.config.ts          # Next.js config
│   │   ├── package.json            # @template/web; depends on @template/{config,db,ui}
│   │   ├── project.json            # NX tags: ["scope:web"]
│   │   ├── tsconfig.json           # Extends tsconfig.base.json
│   │   └── vitest.config.ts        # Vitest config (jsdom environment)
│   └── web-e2e/                    # Playwright E2E suite
│       ├── src/smoke.spec.ts       # Smoke test
│       ├── playwright.config.ts    # Playwright config
│       ├── package.json            # E2E dependencies
│       ├── project.json            # NX tags: ["scope:web"]
│       └── tsconfig.json
├── docs/
│   ├── adr/                        # Architecture Decision Records (see ADR listing below)
│   │   ├── 0000-template.md        # ADR format specification (never delete)
│   │   └── README.md               # ADR process guide
│   └── github/
│       └── secrets.md              # Required repository secrets reference
├── infra/
│   └── github/                     # OpenTofu IaC for GitHub repository settings
│       ├── backend.tf              # GCS state backend (bucket name is TODO placeholder)
│       ├── main.tf                 # Repo, ruleset, environments, labels
│       ├── outputs.tf              # Tofu outputs
│       └── variables.tf            # Input variables (github_token, repo_name, repo_owner)
├── packages/
│   ├── config/                     # @template/config — Zod env validation
│   │   ├── src/index.ts            # parseEnv(), Env type
│   │   ├── src/index.test.ts       # Unit tests
│   │   ├── package.json            # Depends on zod
│   │   ├── project.json            # NX tags: ["scope:shared"]
│   │   └── vitest.config.ts
│   ├── db/                         # @template/db — Prisma singleton + schema
│   │   ├── prisma/
│   │   │   ├── schema.prisma       # PostgreSQL schema; User model scaffold
│   │   │   └── seed.ts             # Database seed script
│   │   ├── src/index.ts            # PrismaClient singleton (globalThis pattern)
│   │   ├── prisma.config.ts        # defineConfig() with explicit schema path
│   │   ├── package.json            # Depends on @prisma/client
│   │   ├── project.json            # NX tags: ["scope:shared"]
│   │   └── tsconfig.json
│   ├── domain/                     # @template/domain — pure business logic (empty scaffold)
│   │   ├── src/index.ts            # Empty export {}
│   │   ├── package.json            # No runtime dependencies
│   │   ├── project.json            # NX tags: ["scope:domain"]
│   │   └── vitest.config.ts
│   └── ui/                         # @template/ui — CVA component library
│       ├── src/
│       │   ├── components/button.tsx       # Button component (CVA)
│       │   ├── components/button.test.tsx  # Button tests
│       │   └── index.ts            # Re-exports Button, ButtonProps
│       ├── package.json            # Peer dep: react; dev: CVA, clsx, tailwind-merge
│       ├── project.json            # NX tags: ["scope:shared"]
│       └── tsconfig.json
├── scripts/
│   ├── ci/                         # Bash governance scripts (each has a .bats test)
│   │   ├── lib/common.sh           # Shared utilities for CI scripts
│   │   ├── validate-adrs.sh        # ADR structure validation
│   │   ├── validate-adrs.bats
│   │   ├── validate-commits.sh     # Conventional commit format check
│   │   ├── validate-commits.bats
│   │   ├── validate-aggregate.sh   # Reads NEEDS_JSON, fails on any non-success
│   │   ├── validate-aggregate.bats
│   │   ├── validate-bats-coverage.sh  # Ensures every .sh has a .bats
│   │   ├── validate-bats-coverage.bats
│   │   ├── run-shellcheck.sh       # Runs shellcheck on all CI scripts
│   │   ├── run-shellcheck.bats
│   │   ├── run-actionlint.sh
│   │   ├── run-actionlint.bats
│   │   ├── run-gitleaks.sh
│   │   ├── run-gitleaks.bats
│   │   ├── check-renovate-token.sh
│   │   └── check-renovate-token.bats
│   └── setup-hooks.sh              # Installs git hooks (run via postinstall)
├── .gitleaks.toml                  # Gitleaks allowlist configuration
├── .nvmrc                          # Node version pin
├── .pre-commit-config.yaml         # Pre-commit hook definitions
├── .prettierrc                     # Prettier formatting config
├── CLAUDE.md                       # Claude Code orientation guide
├── DECISIONS.md                    # Tactical decisions log (not ADRs)
├── PRD.md                          # Full product requirements document
├── commitlint.config.js            # Commitlint config (extends conventional)
├── eslint.config.mjs               # ESLint flat config with @nx/enforce-module-boundaries
├── nx.json                         # NX workspace config (plugins, cache, defaultBase)
├── package.json                    # Root workspace; engines: node>=22
├── renovate.json                   # Renovate dependency update config
├── tsconfig.base.json              # Shared TS compiler options (strict, ES2022, bundler)
└── vercel.json                     # Vercel project config
```

## Directory Purposes

**`apps/web/`:**
- Purpose: Next.js 15 application using App Router
- Contains: React pages/layouts, server components, app-level config
- Key files: `src/app/page.tsx`, `src/app/layout.tsx`, `next.config.ts`
- Depends on: `@template/config`, `@template/db`, `@template/ui`

**`apps/web-e2e/`:**
- Purpose: Playwright end-to-end test suite
- Contains: Spec files against deployed preview URL
- Key files: `src/smoke.spec.ts`, `playwright.config.ts`

**`packages/config/`:**
- Purpose: Runtime environment validation
- Contains: `parseEnv()` function, `Env` type via Zod schema
- Exports: `@template/config` → `{ parseEnv, Env }`

**`packages/db/`:**
- Purpose: Database client and schema ownership
- Contains: Prisma singleton, schema, migrations, seed
- Exports: `@template/db` → `{ prisma }`
- Key constraint: All Prisma CLI commands require `--config packages/db/prisma.config.ts`

**`packages/domain/`:**
- Purpose: Pure business logic — no React, no Prisma client, no framework dependencies
- Contains: Empty scaffold (`export {}`) — instance fills this in as Layer 2
- Exports: `@template/domain`

**`packages/ui/`:**
- Purpose: Shared component library using CVA (class-variance-authority)
- Contains: Typed React components with Tailwind variants
- Exports: `@template/ui` → `{ Button, ButtonProps }`

**`scripts/ci/`:**
- Purpose: Bash implementations of all Phase 0 governance checks
- Invariant: Every `.sh` file must have a matching `.bats` test file (enforced by `validate-bats-coverage.sh`)
- Key file: `lib/common.sh` — shared violation tracking and reporting utilities

**`docs/adr/`:**
- Purpose: Permanent record of significant architectural decisions
- Invariant: `0000-template.md` and `README.md` are never validated and never deleted
- Instance ADRs: `0100+`

**`infra/github/`:**
- Purpose: OpenTofu IaC for GitHub repository configuration
- Status: Written but never applied (bootstrap blocker — GCS bucket not yet created)

**`.specify/memory/`:**
- Purpose: Project constitution and governance philosophy
- Key file: `constitution.md` — replaced with instance-specific constitution post-instantiation

## Key File Locations

**Entry Points:**
- `apps/web/src/app/page.tsx`: Next.js root page
- `apps/web/src/app/layout.tsx`: Next.js root layout
- `packages/db/src/index.ts`: Prisma singleton export

**Configuration:**
- `nx.json`: NX workspace plugins, cache config, `defaultBase: "main"`
- `tsconfig.base.json`: Shared TypeScript options (strict, ES2022, bundler moduleResolution)
- `eslint.config.mjs`: Module boundary enforcement rules
- `commitlint.config.js`: Conventional commit validation
- `packages/db/prisma.config.ts`: Prisma configuration (schema path, datasource)
- `packages/db/prisma/schema.prisma`: Database schema (PostgreSQL, User model)

**CI Workflows:**
- `.github/workflows/1-commit.yml`: Primary gate (sole required status check)
- `.github/workflows/2-e2e.yml`: E2E stage
- `.github/workflows/3-promote.yml`: Production promotion
- `.github/workflows/infra.yml`: OpenTofu plan/apply

**Governance Scripts:**
- `scripts/ci/validate-adrs.sh`: ADR structure validator
- `scripts/ci/validate-aggregate.sh`: Reads `NEEDS_JSON`, fails on any non-success
- `scripts/ci/validate-bats-coverage.sh`: Enforces .sh → .bats pairing
- `scripts/ci/lib/common.sh`: Shared violation tracking

## NX Project Graph

**Dependency edges (declared in `package.json` `dependencies`):**

```
apps/web (@template/web)
  └── packages/config (@template/config)
  └── packages/db    (@template/db)
  └── packages/ui    (@template/ui)

apps/web-e2e
  └── (no internal deps — tests against deployed URL)

packages/ui (@template/ui)
  └── (no internal deps — peer dep on react only)

packages/config (@template/config)
  └── (no internal deps — dev dep on zod only)

packages/db (@template/db)
  └── (no internal deps — depends on @prisma/client only)

packages/domain (@template/domain)
  └── (no internal deps — empty scaffold)
```

**NX scope tags (enforce module boundaries via ESLint):**

| Project | Tag | May import from |
|---------|-----|-----------------|
| `apps/web` | `scope:web` | `scope:web`, `scope:domain`, `scope:shared` |
| `apps/web-e2e` | `scope:web` | `scope:web`, `scope:domain`, `scope:shared` |
| `packages/ui` | `scope:shared` | `scope:shared` |
| `packages/config` | `scope:shared` | `scope:shared` |
| `packages/db` | `scope:shared` | `scope:shared` |
| `packages/domain` | `scope:domain` | `scope:domain`, `scope:shared` |

## Package Namespace

All packages use the `@template/*` namespace:
- `@template/web` — Next.js app
- `@template/config` — env validation
- `@template/db` — Prisma singleton
- `@template/domain` — business logic
- `@template/ui` — component library

**On instantiation:** Rename all `@template/*` → `@<project-slug>/*` in all `package.json` files and update all imports before first Layer 2 commit.

## ADR File Listing

| File | Status |
|------|--------|
| `0001-snapshot-model.md` | accepted |
| `0002-aggregate-validator.md` | accepted |
| `0003-nextjs-vercel-prisma.md` | accepted |
| `0004-opentofu-github-governance.md` | accepted |
| `0005-phase-zero-gate.md` | accepted |
| `0006-deploy-chain-ordering.md` | accepted |
| `0007-incident-dora-instrumentation.md` | accepted |
| `0008-branch-protection-reviewers-automerge.md` | accepted |
| `0010-prisma-config-required.md` | proposed |
| `0011-nx-module-boundary-tags.md` | proposed |
| `0012-1-commit-trigger-scope.md` | proposed |
| `0013-ci-conventions-ignore-scripts-env-vars.md` | proposed |
| `0015-bats-stub-policy.md` | proposed |
| `0016-vitest-config-per-package.md` | proposed |
| `0017-domain-package-boundary-enforcement.md` | proposed |
| `0018-ci-workflow-drift-from-spec.md` | proposed |
| `0020-prisma-singleton-pattern.md` | proposed |
| `0021-renovate-pin-strategy.md` | proposed |
| `0022-nx-module-boundaries-tags.md` | proposed |
| `0023-1-commit-phase0-completeness.md` | proposed |

8 accepted, 12 proposed. Numbers 0009, 0014, 0019 are intentionally absent (skipped).

## Naming Conventions

**Files:**
- ADRs: `NNNN-kebab-case-title.md` in `docs/adr/`
- CI scripts: `verb-noun.sh` with matching `verb-noun.bats` in `scripts/ci/`
- Workflows: `N-name.yml` (numbered) or `name.yml` (utility) in `.github/workflows/`
- TypeScript source: `kebab-case.ts`, `kebab-case.test.ts`, `kebab-case.tsx`

**Directories:**
- App packages: `apps/<name>/` — runnable applications
- Library packages: `packages/<name>/` — shared libraries consumed by apps

## Where to Add New Code

**New Next.js page/route:**
- Implementation: `apps/web/src/app/<route>/page.tsx`
- Tests: `apps/web/src/app/<route>/page.test.tsx` (co-located)

**New UI component:**
- Implementation: `packages/ui/src/components/<component>.tsx`
- Tests: `packages/ui/src/components/<component>.test.tsx`
- Export: add to `packages/ui/src/index.ts`

**New domain logic:**
- Implementation: `packages/domain/src/<feature>.ts`
- Tests: `packages/domain/src/<feature>.test.ts`
- Constraint: no React, no `@prisma/client`, no framework imports

**New env variable:**
- Add to Zod schema in `packages/config/src/index.ts`
- Update `docs/github/secrets.md`

**New CI governance script:**
- Implementation: `scripts/ci/<verb>-<noun>.sh`
- Tests: `scripts/ci/<verb>-<noun>.bats` (required — `validate-bats-coverage.sh` enforces pairing)
- Register in Phase 0 `needs:` in `.github/workflows/1-commit.yml`
- Add to `commit-validation` `needs:` array

**New ADR:**
- File: `docs/adr/NNNN-kebab-title.md` (template instances start at `0100`)
- Use `0000-template.md` as format spec
- Run `bash scripts/ci/validate-adrs.sh docs/adr` to validate locally

**New OpenTofu resource:**
- Add to `infra/github/main.tf`
- Outputs to `infra/github/outputs.tf`
- Variables to `infra/github/variables.tf`
- CI applies automatically via `infra.yml` on push to main

## Special Directories

**`.nx/`:**
- Purpose: NX computation cache and workspace data
- Generated: Yes
- Committed: No (`.nx/cache/` gitignored; `.nx/workspace-data/` may be partially committed)

**`.planning/codebase/`:**
- Purpose: GSD codebase map documents
- Generated: Yes (by `/gsd-map-codebase`)
- Committed: Yes

**`.specify/`:**
- Purpose: Project constitution and governance memory
- Key file: `.specify/memory/constitution.md` — replace with instance constitution post-instantiation
- Committed: Yes

---

*Structure analysis: 2026-06-28*
