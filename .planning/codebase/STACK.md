# Technology Stack

**Analysis Date:** 2026-06-28

## Languages

**Primary:**
- TypeScript `^5.8.0` — all source code across `apps/` and `packages/`
- Bash — CI scripts in `scripts/ci/`, git hooks in `scripts/setup-hooks.sh`

**Secondary:**
- HCL (OpenTofu/Terraform) — infrastructure-as-code in `infra/github/`

## Runtime

**Environment:**
- Node.js `>=22` (required; `"engines": { "node": ">=22" }` in root `package.json`)
- Node version pinned at `22` via `.nvmrc`
- Use `fnm use 22` or `nvm use 22` before running npm commands

**Module System:**
- ESM (`"type": "module"` in root `package.json`)
- TypeScript targets `ES2022`, module resolution: `bundler` (see `tsconfig.base.json`)

**Package Manager:**
- npm (workspaces declared in root `package.json`: `["apps/*", "packages/*"]`)
- CI uses `npm ci --ignore-scripts` (see `.github/workflows/1-commit.yml`)
- Lockfile: `package-lock.json` (npm)

## Frameworks

**Core:**
- Next.js `^15.0.0` — web application (`apps/web/`)
- React `^19.0.0` + `react-dom ^19.0.0` — UI rendering (`apps/web/`)

**Testing:**
- Vitest `^4.1.9` — unit/integration tests for `apps/web/` (`apps/web/package.json`)
- Vitest `^3.0.0` — unit tests for `packages/config/` and `packages/domain/`
- Playwright `^1.50.0` (`@playwright/test`) — E2E tests in `apps/web-e2e/`
- BATS (Bash Automated Testing System) — shell script tests in `scripts/ci/*.bats`

**Build/Dev:**
- NX `^22.0.0` — monorepo task orchestration (`nx.json`)
- `@nx/next ^22.0.0` — NX plugin for Next.js build/dev targets
- `@nx/vite ^22.0.0` — NX plugin wiring Vitest as `test` target
- `@nx/eslint ^22.0.0` — NX plugin wiring ESLint as `lint` target
- `@nx/playwright ^22.0.0` — NX plugin wiring Playwright as `e2e` target

## Key Dependencies

**Critical:**
- `prisma ^7.0.0` / `@prisma/client ^7.0.0` — ORM and generated client (`packages/db/`)
- `zod ^3.23.0` — environment variable schema validation (`packages/config/`)
- `tsx` — used for database seed script (`packages/db/prisma/seed.ts`) via `db:seed` script

**UI Utilities (devDependencies in `packages/ui/`):**
- `class-variance-authority ^0.7.0` — CVA component variant API
- `clsx ^2.0.0` — conditional classname utility
- `tailwind-merge ^2.0.0` — Tailwind class deduplication

**Commit Enforcement:**
- `@commitlint/cli ^19.0.0` — commit message linting
- `@commitlint/config-conventional ^19.0.0` — conventional commits rule set

## Configuration

**TypeScript:**
- Base config: `tsconfig.base.json` (strict mode, `noUncheckedIndexedAccess`, `exactOptionalPropertyTypes`)
- Per-package `tsconfig.json` files extend the base

**ESLint:**
- Config: `eslint.config.mjs` (flat config, ESLint 9)
- Rules: `@nx/enforce-module-boundaries` with tag-based dependency constraints
  - `scope:web` → may depend on `scope:web`, `scope:domain`, `scope:shared`
  - `scope:domain` → may depend on `scope:domain`, `scope:shared`
  - `scope:shared` → may depend on `scope:shared` only

**Commitlint:**
- Config: `commitlint.config.js`
- Extends `@commitlint/config-conventional`
- Header max 72 chars; allowed types: `feat`, `fix`, `chore`, `docs`, `test`, `refactor`, `perf`, `ci`, `build`, `revert`

**Pre-commit Hooks:**
- Config: `.pre-commit-config.yaml` (pre-commit framework, `v4.6.0` hooks)
- Hooks: trailing whitespace, EOF fixer, YAML/JSON check, merge conflict check, case conflict check, LF line endings
- Local hooks: ADR structure validation, commitlint (commit-msg stage), gitleaks secret scan, actionlint workflow lint, shellcheck shell lint

**Vitest:**
- `apps/web/vitest.config.ts`: environment `jsdom`, includes `src/**/*.{test,spec}.{ts,tsx}`
- `packages/config/vitest.config.ts`: environment `node`, includes `src/**/*.{test,spec}.ts`
- `packages/domain/vitest.config.ts`: environment `node` (same pattern)

**Playwright:**
- Config: `apps/web-e2e/playwright.config.ts`
- Browser: Chromium only
- Base URL: `process.env.PLAYWRIGHT_BASE_URL ?? 'http://localhost:3000'`

**NX:**
- Config: `nx.json`
- `defaultBase: "main"`
- Caching enabled for `build`, `test`, `lint`, `typecheck` targets
- Plugins auto-infer targets from project configs (no explicit `project.json` targets needed)

## Platform Requirements

**Development:**
- Node.js 22 (`fnm use 22` recommended)
- `npm install` triggers `scripts/setup-hooks.sh` via `postinstall`
- `DATABASE_URL` env var required for Prisma operations
- pre-commit framework must be installed for hooks to run

**Production:**
- Deployed to Vercel (see INTEGRATIONS.md)
- Database: PostgreSQL (any provider, connection via `DATABASE_URL`)

**Infrastructure:**
- OpenTofu `>=1.6` for GitHub IaC (`infra/github/`)
- GCS bucket required for Terraform state backend (not yet configured)

---

*Stack analysis: 2026-06-28*
