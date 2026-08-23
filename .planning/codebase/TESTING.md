# Testing Patterns

**Analysis Date:** 2026-06-28

## BATS Test Suite

**Runner:** BATS (Bash Automated Testing System)

**Location:** `scripts/ci/` — each `.sh` has a sibling `.bats` at the same path

**Current suites:**

| Suite | Tests |
|---|---|
| `scripts/ci/validate-adrs.bats` | ADR validation rules (14 tests) |
| `scripts/ci/validate-commits.bats` | Commit message linting (4 tests) |
| `scripts/ci/validate-bats-coverage.bats` | BATS sibling rule enforcement (4 tests) |
| `scripts/ci/run-shellcheck.bats` | Shell lint invocation |
| `scripts/ci/run-gitleaks.bats` | Secret scan invocation |
| `scripts/ci/run-actionlint.bats` | Workflow lint invocation |
| `scripts/ci/validate-aggregate.bats` | CI aggregate job logic |
| `scripts/ci/check-renovate-token.bats` | Renovate token check |

**BATS sibling rule:** Every `.sh` in `scripts/ci/` at depth 1 must have a matching `.bats`. Enforced by `scripts/ci/validate-bats-coverage.sh`, which runs both as a pre-commit hook and as a CI Phase 0 job.

**Run command:**
```bash
bats scripts/ci/validate-adrs.bats
bats scripts/ci/validate-commits.bats
# or all at once:
bats scripts/ci/*.bats
```

---

## BATS Test Structure

**Setup/teardown pattern:**
```bash
setup() {
  VALIDATOR="$(cd "$(dirname "$BATS_TEST_FILENAME")" && pwd)/validate-adrs.sh"
  WORK_DIR="$(mktemp -d)"
  mkdir -p "$WORK_DIR/docs/adr"
  cd "$WORK_DIR"
}

teardown() {
  rm -rf "$WORK_DIR"
}
```

Each suite creates a temp directory and `cd`s into it. The teardown removes it. The validator script path is resolved relative to `$BATS_TEST_FILENAME` to make suites relocatable.

**Test invocation pattern:**
```bash
@test "description of expected behavior" {
  run "$VALIDATOR" args
  [ "$status" -eq 0 ]
  [[ "$output" == *"expected substring"* ]]
}
```

**Fixture helper in `validate-adrs.bats`:**
```bash
write_valid_adr() {
  local number="$1" slug="$2" status="${3:-proposed}"
  cat > "docs/adr/$number-$slug.md" <<EOF
---
status: $status
date: 2026-06-10
tags: [process]
---
## Context
...
## Decision
...
## Consequences
...
EOF
}
```

**Git fixture helpers in `validate-commits.bats`:**
```bash
create_seeded_origin()   # git init + initial commit in tmp dir
clone_fixture_repo()     # git clone origin into test clone dir
configure_identity()     # sets user.name, user.email, commit.gpgsign=false
fixture_commit()         # commit_in $CLONE_DIR with given message
```

---

## `validate-bats-coverage.sh` Enforcement

**What it checks:** For every `*.sh` file in `scripts/ci/` (maxdepth 1), verifies a sibling `*.bats` file exists at the same path with the `.sh` extension replaced by `.bats`.

**Failure message format:** `scripts/ci/X.sh: missing sibling BATS suite scripts/ci/X.bats`

**Enforcement:** Phase 0 in `1-commit.yml` (`validate-bats-coverage` job) + pre-commit hook via `.pre-commit-config.yaml`.

Adding a new `scripts/ci/*.sh` requires adding a matching `scripts/ci/*.bats` in the same commit or CI will fail.

---

## NX / Vitest Test Runner

**Framework:** Vitest (via `@nx/vite` plugin, `nx.json`)

**Run commands:**
```bash
npx nx run-many -t test          # all packages
npx nx run web:test              # single package
```

**Per-workspace configs:**

| Package | Config | Environment | Pattern |
|---|---|---|---|
| `apps/web` | `apps/web/vitest.config.ts` | `jsdom` | `src/**/*.{test,spec}.{ts,tsx}` |
| `packages/config` | `packages/config/vitest.config.ts` | `node` | `src/**/*.{test,spec}.ts` |
| `packages/domain` | `packages/domain/vitest.config.ts` | `node` | `src/**/*.{test,spec}.ts` |
| `packages/ui` | (inherits NX plugin default) | — | `src/**/*.{test,spec}.{ts,tsx}` |

All configs set `passWithNoTests: true`.

**NX caching:** `test` target is cached with inputs `["default", "^production"]` (see `nx.json` `targetDefaults`).

---

## Vitest Test Structure

**Imports:**
```typescript
import { describe, it, expect } from 'vitest';
```

**Suite pattern:**
```typescript
describe('ModuleName', () => {
  it('does the expected thing', () => {
    const result = moduleFunction(input);
    expect(result).toBe(expected);
  });
});
```

**Existing unit tests:**

- `packages/config/src/index.test.ts` — tests `parseEnv()` for missing and valid `DATABASE_URL`
- `packages/ui/src/components/button.test.tsx` — scaffolding test: asserts `typeof Button === 'function'`

No mocking patterns, fixtures, or factories are in use yet. Test utilities are not yet abstracted.

---

## Playwright E2E Tests

**Location:** `apps/web-e2e/src/`

**Config:** `apps/web-e2e/playwright.config.ts`

**Browser:** Chromium (Desktop Chrome) only

**Key config:**
```typescript
{
  testDir: './src',
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  workers: process.env.CI ? 1 : undefined,
  reporter: 'html',
  use: {
    baseURL: process.env.PLAYWRIGHT_BASE_URL ?? 'http://localhost:3000',
    trace: 'on-first-retry',
  },
}
```

**Run command:**
```bash
npx nx run web-e2e:e2e
# or via npm script:
npm run e2e
```

**Existing specs:** `apps/web-e2e/src/smoke.spec.ts` (2 tests: title check, heading visibility)

**Test pattern:**
```typescript
import { test, expect } from '@playwright/test';

test('home page has correct title', async ({ page }) => {
  await page.goto('/');
  await expect(page).toHaveTitle(/tgh-template/);
});
```

---

## CI Test Execution

**Phase 0 (governance, `1-commit.yml`):**
- `validate-bats-coverage` — ensures BATS sibling coverage; BATS suites themselves are not run in CI (they require the local environment)

**Phase 1 (compute, gated by Phase 0):**
- `test` job — `npx nx run-many -t test` (Vitest across all packages)
- Runs on `ubuntu-24.04`, Node 22

**`2-e2e.yml` (separate workflow):**
- Triggered by: `workflow_run` on "Commit Validation" completing on `main`, or `workflow_dispatch`
- Runs: `npx nx run web-e2e:e2e`
- Requires secret: `VERCEL_PREVIEW_URL` (sets `PLAYWRIGHT_BASE_URL`)
- Uploads HTML report artifact on failure (7-day retention)
- Does NOT run on feature branches — only `main` after CI passes

---

## Coverage Requirements

No coverage thresholds are configured in any Vitest config. `passWithNoTests: true` is set globally — packages with no tests do not fail CI.

No coverage report generation is configured in CI.

---

*Testing analysis: 2026-06-28*
