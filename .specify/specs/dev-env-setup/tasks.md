# Tasks: Dev Environment Setup

Test-first ordering. Each "verify" task is the red step; each "fix" task is the green step.

---

## Phase 1: Package manifest correctness

- [x] Task 1 (RED): Confirm `pnpm install` fails due to stale lockfile
  - Expected: version mismatch or missing package error without frozen-lockfile note
- [x] Task 2 (GREEN): Move `zod` from `devDependencies` to `dependencies` in `packages/config/package.json`
- [x] Task 3 (GREEN): Rename root `package.json` `name` from `tgh-template` to `evan-school`
- [x] Task 4 (GREEN): Run `pnpm install` on Node 22 — lockfile regenerated with `@evan-school/*` and `@clerk/nextjs`
  - Verify: lockfile now contains `@evan-school/config`, `@evan-school/db`, `@evan-school/ui`, `@clerk/nextjs`

## Phase 2: Type generation

- [x] Task 5 (RED): Confirm `pnpm run typecheck` fails before `prisma generate`
  - Expected: cannot find module '@prisma/client' or type errors in db package
- [x] Task 6 (GREEN): Run `prisma generate` with dummy DATABASE_URL
  - Verify: `.pnpm/@prisma/client*/node_modules/.prisma/client/` contains generated files

## Phase 3: Type checking

- [x] Task 7 (RED/GREEN): Run `pnpm run typecheck` — verify exit 0

## Phase 4: Build

- [x] Task 8 (RED/GREEN): Run `pnpm run build` — verify exit 0

## Phase 5: Developer documentation

- [x] Task 9: Create `.env.local.example` documenting required env vars

## Phase 6: Commit

- [x] Task 10: Commit all changes with conventional commit message
  - `chore: bootstrap dev environment (lockfile, zod dep, package name)`
