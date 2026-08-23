# Coding Conventions

**Analysis Date:** 2026-06-28

## Commit Message Conventions

**Enforcer:** `commitlint.config.js` + `scripts/ci/validate-commits.sh`

**Format:** `<type>(<scope>)?!?: <subject>`

**Rules:**
- Header max length: 72 characters (enforced by both commitlint and `validate-commits.sh`)
- Subject must NOT start with an uppercase letter
- Subject case styles forbidden: sentence-case, start-case, pascal-case, upper-case
- Merge PR commits (`Merge pull request #N` or `Merge branch '...`) are skipped from validation

**Allowed types:** `feat`, `fix`, `chore`, `docs`, `test`, `refactor`, `perf`, `ci`, `build`, `revert`

**Enforcement points:**
1. `commit-msg` hook — `npx commitlint --edit` (via `.pre-commit-config.yaml`)
2. CI Phase 0 — `bash scripts/ci/validate-commits.sh` in `1-commit.yml`

**Pattern matched:** `^(feat|fix|chore|docs|test|refactor|perf|ci|build|revert)(\(.+\))?!?: `

---

## ADR Discipline

**Location:** `docs/adr/`

**Filename pattern:** `NNNN-kebab-case-title.md` (4-digit zero-padded number required)

**Skipped files:** `0000-template.md`, `README.md` (never validate these)

**Required frontmatter keys:**
```yaml
---
status: accepted          # proposed | accepted | rejected | deprecated | superseded
date: YYYY-MM-DD
tags: [tag1, tag2]
implementation: path/to/file  # REQUIRED when status=accepted AND tags includes "tooling"
---
```

**Required body sections (exact headings):**
- `## Context`
- `## Decision`
- `## Consequences`

**Numbering rules:**
- `0001–0005` are template meta ADRs — do not modify in instances
- `0000-template.md` is the format spec — never delete, never validate
- Instances (new projects) start their own ADRs at `0100+`

**Validation script:** `scripts/ci/validate-adrs.sh docs/adr`
Enforced at: pre-commit hook (on `docs/adr/*.md` changes) + CI Phase 0

---

## Shell Script Conventions

**Shebang:** `#!/usr/bin/env bash`

**Safety flags (required on every script):** `set -euo pipefail`

**Linting:** `shellcheck -x -P SCRIPTDIR --severity=warning`
- Scanned directories: `scripts/` and `.github/scripts/`
- Cross-file sourcing uses `# shellcheck source=lib/common.sh` annotations

**Script directory pattern (required for portability):**
```bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"
```

**BATS sibling rule:** Every `.sh` in `scripts/ci/` (at depth 1) must have a sibling `.bats` file with the same base name. Enforced by `scripts/ci/validate-bats-coverage.sh`.

**Shared library:** `scripts/ci/lib/common.sh` provides:
- `log()` — stdout line
- `die()` — stderr + exit 1
- `require_inside_git_repo()` — guard
- `add_violation()` / `report_violations()` — collect errors and exit 1 if any

**Enforcement:** shellcheck runs as pre-commit hook (on `*.sh` changes) + CI Phase 0

---

## TypeScript Conventions

**Config base:** `tsconfig.base.json` (inherited by all workspace packages)

**Compiler settings:**
- `"strict": true`
- `"noUncheckedIndexedAccess": true`
- `"exactOptionalPropertyTypes": true`
- `"target": "ES2022"`
- `"module": "ESNext"`
- `"moduleResolution": "bundler"`
- `"declaration": true`, `"declarationMap": true`, `"sourceMap": true`
- `"esModuleInterop": true`, `"skipLibCheck": true`

**Node version requirement:** `>=22` (set in `package.json` `engines` field)

**ESM-first:** Root `package.json` has `"type": "module"`

---

## ESLint Conventions

**Config file:** `eslint.config.mjs` (flat config format, ESLint v9+)

**Rule layers (in order):**
1. `js.configs.recommended` (`@eslint/js`)
2. `tseslint.configs.recommended` (`typescript-eslint`)
3. `nx.configs['flat/base']`, `nx.configs['flat/typescript']`, `nx.configs['flat/react']`
4. `@nx/enforce-module-boundaries` (see NX Tags below)

**Ignores:** `node_modules/**`, `dist/**`, `.next/**`, `.nx/**`

**Run lint:** `npx nx run-many -t lint`

---

## NX Project Tags and Module Boundaries

**Rule:** `@nx/enforce-module-boundaries` at error severity

**Tags in use:**

| Tag | Assigned to |
|---|---|
| `scope:web` | `apps/web`, `apps/web-e2e` |
| `scope:domain` | `packages/domain` |
| `scope:shared` | `packages/ui`, `packages/config`, `packages/db` |

**Dependency constraints:**

| Source tag | May depend on |
|---|---|
| `scope:web` | `scope:web`, `scope:domain`, `scope:shared` |
| `scope:domain` | `scope:domain`, `scope:shared` |
| `scope:shared` | `scope:shared` only |

Each project declares its tag(s) in its `project.json` `tags` array.

---

## Package Naming

**Template namespace:** `@template/*`

**Rule for instances:** Rename all packages from `@template/*` to `@<project-slug>/*` (e.g., `@mde/*`) and update all imports before the first Layer 2 commit. Update all `package.json` `name` fields across `apps/` and `packages/`.

---

## Git Hooks

**Installation:** `scripts/setup-hooks.sh` (runs automatically as `npm postinstall`)
```bash
pre-commit install --hook-type pre-commit --hook-type commit-msg
```

**`pre-commit` stage hooks** (from `.pre-commit-config.yaml`):

| Hook | Trigger | What it enforces |
|---|---|---|
| `trailing-whitespace` | any file | no trailing whitespace |
| `end-of-file-fixer` | any file | newline at EOF |
| `check-yaml` | any file | valid YAML syntax |
| `check-json` | `*.json` (excl. `tsconfig*.json`) | valid JSON syntax |
| `check-merge-conflict` | any file | no merge conflict markers |
| `check-case-conflict` | any file | no case-only filename conflicts |
| `mixed-line-ending` | any file | forces LF line endings |
| `validate-adrs` | `docs/adr/*.md` | ADR frontmatter + sections |
| `gitleaks` | always | secret scanning (staged files) |
| `actionlint` | `.github/workflows/*.yml` | workflow YAML lint |
| `shellcheck` | `*.sh` | shell script lint |

**`commit-msg` stage hooks:**

| Hook | What it enforces |
|---|---|
| `commitlint` | Conventional commit format, 72-char header, lowercase subject |

---

## DECISIONS.md vs ADRs

**`DECISIONS.md`** (`/Users/thomasghenry/code/tgh-template/DECISIONS.md`):
- Tabular log of tactical, reversible, or implementation-specific choices
- No ceremony, no validation, no required structure beyond a table row
- Format: `| Date | Decision | Alternatives considered | Rationale |`
- Use when: the decision is low-stakes, quickly reversible, or too small to warrant a full ADR

**`docs/adr/`:**
- Architectural decisions with significant tradeoffs or long-term impact
- Full frontmatter + required sections enforced by CI and pre-commit
- Guides future choices across projects and instances
- Use when: the decision is architectural, has meaningful tradeoffs, or will influence the shape of the codebase

---

*Convention analysis: 2026-06-28*
