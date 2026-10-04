# Agent Context — tgh-template

This file is the canonical agent entry point for this repository. `CLAUDE.md` and
`GEMINI.md` are symlinks to this file. All agent systems read identical content.

## TOC — Where Things Live

| Concern | Location |
|---|---|
| Governing rule + governance philosophy | `.specify/memory/constitution.md` |
| Product requirements + rationale | `PRD.md` |
| Architectural decisions | `docs/adr/` (template: 0001–0099; instances: 0100+) |
| CI pipeline | `.github/workflows/1-commit.yml` |
| IaC — one-time bootstrap | `infra/bootstrap/` |
| IaC — GitHub config (pipeline-managed) | `infra/github/` |
| IaC — platform (Vercel, environments) | `infra/platform/` |
| Spec kit memory | `.specify/memory/` |
| Spec kit hooks | `.specify/extensions.yml` |
| Codebase analysis docs | `.planning/codebase/` |
| Web application | `apps/web/src/` |
| UI components + design tokens | `packages/ui/src/` |
| Domain logic | `packages/domain/src/` |
| Env validation | `packages/config/src/` |
| Prisma schema + client | `packages/db/` |

## What Agents Must Not Do

- Mutate cloud state (GitHub config, GCP resources, Vercel config, any hosted service)
  outside the CI pipeline. The bootstrap modules (`infra/bootstrap/`, `infra/github/`,
  `infra/platform/`) are the one named exception — run once, documented.
- Suggest creating GitHub labels, repository settings, or branch protection manually.
  These are infrastructure. They go through OpenTofu via the pipeline.
- Use `--no-verify` or `-n` with any git command. Pre-commit hooks are sacred.
- Include `Claude-Session:` trailers in commit messages.
- Perform destructive or production-affecting actions (deploy, destroy infra, delete
  data, rotate secrets) without explicit human authorisation.
- Add abstractions not traceable to an earned scar or a current experiment. Before
  adding any abstraction, ask: is this pattern proven in a sister project, or is this a
  named current experiment? If neither, do not add it.
- Modify Layer 2 code. This repository is a template — Layer 2 (instance-specific
  application logic) belongs in the instantiated project, not here.

## What this repo is

`ThomasGHenry/tgh-template` is a GitHub Template Repository — a governance-first
monorepo scaffold for personal projects. It is a **snapshot, not a generator**. New
projects are created by clicking "Use this template" (or `gh repo create --template`),
not by running a setup script.

Three-layer model:
- **Layer 0** — Stack-agnostic governance: ADR enforcement, conventional commits, secret
  scanning, shell lint, CI gate structure, GitHub IaC. Lives in `scripts/ci/`,
  `.github/workflows/`, `infra/`, `docs/adr/`, `.pre-commit-config.yaml`.
- **Layer 1** — nextjs-vercel-prisma overlay: NX monorepo scaffold, Prisma singleton,
  CVA UI components, Zod env validation. Lives in `apps/`, `packages/`, `nx.json`,
  `tsconfig.base.json`.
- **Layer 2** — Instance-specific application logic. **Not in this template.** Each
  instantiated project builds its own Layer 2 on top.

Full design rationale: `PRD.md`. Key decisions: `docs/adr/`. Governance philosophy:
`.specify/memory/constitution.md`.

## Commands

```bash
# Verify governance scripts pass locally
bash scripts/ci/validate-adrs.sh docs/adr
bash scripts/ci/validate-commits.sh
bash scripts/ci/validate-bats-coverage.sh
bash scripts/ci/run-shellcheck.sh

# Run BATS test suites
bats scripts/ci/validate-adrs.bats
bats scripts/ci/validate-commits.bats
bats scripts/ci/*.bats   # run all suites at once

# NX (requires Node 22 — run `fnm use 22` first)
pnpm install
pnpm run typecheck   # pnpm exec nx run-many -t typecheck
pnpm run lint        # pnpm exec nx run-many -t lint
pnpm run test        # pnpm exec nx run-many -t test
pnpm run build       # pnpm exec nx run-many -t build

# Prisma (always pass --config)
pnpm run db:generate
pnpm run db:migrate
pnpm run db:studio
```

## CI pipeline

`1-commit.yml` is the sole required workflow. It runs in phases:

- **Phase 0** (governance, all parallel): `changes` (dorny/paths-filter), `gitleaks`,
  `actionlint`, `validate-adrs`, `validate-commits`, `shellcheck`,
  `validate-bats-coverage`, `validate-speckit`, `supply-chain-policy`, `prisma-migrate-check`
- **Phase 1** (compute, path-filtered, gated by Phase 0): `typecheck`, `lint`, `test`,
  `build`; `coverage-gate` downloads LCOV artifact and runs `ratchet-coverage.sh`
- **Phase 2** (gated by Phase 1): E2E smoke via `resolve-vercel-deployment.sh` + Playwright
- **Aggregate**: `commit-validation` reads `$NEEDS_JSON`; fails if any required job did
  not succeed. This is the **sole required GitHub status check** in branch protection.

Adding a new Phase 0 job: add it to `1-commit.yml` **and** to `commit-validation`'s
`needs:` array. Branch protection settings do not change.

## ADR discipline

All ADRs live in `docs/adr/` with YAML frontmatter:

```yaml
---
status: accepted          # proposed | accepted | deprecated | superseded
date: YYYY-MM-DD
tags: [tag1, tag2]
implementation: path/to/file.ts   # required when status=accepted and tags include tooling
supersedes: 0000-slug.md          # optional — triggers bidirectional validation
---
```

Required sections: `## Context`, `## Decision`, `## Consequences`.
Optional sections: `## Hypothesis` (pre-implementation), `## Findings` (post-implementation).

- `0000-template.md` — format spec, never delete, never validate
- `0001–0099` — template meta-ADRs, do not modify in instances
- Instances start their own ADRs at `0100+`
- Bidirectional supersession: if A `supersedes` B, CI validates that B has `status: superseded`

Validate locally: `bash scripts/ci/validate-adrs.sh docs/adr`

## Shell script conventions

Every `scripts/ci/*.sh` must have a sibling `scripts/ci/*.bats` or `validate-bats-coverage`
fails Phase 0. New scripts must ship with their BATS suite in the same commit.

All scripts require `#!/usr/bin/env bash` and `set -euo pipefail`. Source shared
utilities from `scripts/ci/lib/common.sh` via the `SCRIPT_DIR` pattern:

```bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"
```

## Bootstrap status

**Pending before template is production-ready:**

### 1. Tofu apply (GitHub settings + Vercel)

`infra/` has three modules run in sequence:

1. `infra/bootstrap/` — create GitHub App + R2 state bucket (one-time, manual)
2. `infra/github/` — branch protection, labels, environments (pipeline-managed after bootstrap)
3. `infra/platform/` — Vercel project, environments, env vars

Until applied: branch protection inactive, labels not created, environments absent.

See `docs/github/secrets.md` for the full secrets list.

### 2. Vercel secrets

`2-e2e.yml` and `3-promote.yml` expect: `VERCEL_TOKEN`, `VERCEL_PROJECT_ID`,
`DATABASE_URL_PROD`. Until set, those workflows fail. `1-commit` is unaffected.

### 3. Repo visibility

Currently **private**. PRD requires public (ADR 0001). `infra/github/main.tf` sets
`visibility = "public"` — Tofu apply (step 1) fixes this.

## Instantiation

```bash
# Create a new project from this template
gh repo create ThomasGHenry/<project-name> --template ThomasGHenry/tgh-template --private

# Clone and set up
git clone git@github.com:ThomasGHenry/<project-name>.git ~/code/<project-name>
cd ~/code/<project-name>
pnpm install

# Validate governance inherited correctly
bash scripts/ci/validate-adrs.sh docs/adr

# Post-instantiation steps
# 1. Replace .specify/memory/constitution.md with your project constitution
# 2. Replace .specify/memory/north-star.md with your project north star
# 3. Rename @template/* → @<project-slug>/* in all package.json files
# 4. Add your first ADR at docs/adr/0100-*.md
# 5. Run infra/bootstrap/ to activate branch protection and create labels
```

## Package namespace

Template ships as `@template/*`. Instances rename to `@<project-slug>/*` (e.g. `@mde/*`)
and update all imports before first Layer 2 commit.

## Key constraints

- Personal account only: `ThomasGHenry`. Never Agora (`ThomasGHenry-a`).
- All `git push` via `env -u GH_TOKEN git push` to avoid stale token interference.
- Never `--no-verify` on any git command. Hooks are sacred.
- Conventional commits enforced at `commit-msg` hook and in CI. Header ≤ 72 chars.
- PR titles must start **lowercase** after the `type:` prefix. `docs: seo strategy` not `docs: SEO Strategy`. GitHub appends ` (#NNN)` on squash-merge (excluded from the 72-char count per ADR 0123), but the case rule applies to the authored title and is not auto-corrected.
- Node 22 required. Run `fnm use 22` before pnpm commands.
- pnpm 10+ required. Use `pnpm install --frozen-lockfile` in CI.
- Every `scripts/ci/*.sh` must ship with a sibling `.bats` file in the same commit.
