---
status: accepted
date: 2026-07-07
tags: [tooling]
implementation: .github/workflows/1-commit.yml
---

# 0028. Path-Based Change Detection in CI

## Context

All Phase 1 jobs (typecheck, lint, test, build) ran unconditionally, costing full
compute time on doc-only or infra-only commits. With multiple packages in the monorepo,
changes to `docs/adr/` should not trigger a full NX build.

## Decision

Add a `changes` Phase 0 job using `dorny/paths-filter@v3`. Phase 1 jobs gate on
relevant path outputs: `web`, `packages`, `db`, `infra`, `scripts`, `docs`. Governance
jobs (Phase 0) always run — they are cheap and path-gating them creates false confidence.

`commit-validation` aggregate uses `if: always()` and `validate-aggregate.sh` treats
`skipped` as acceptable (not a failure). On `push` to main, all jobs run regardless of
path filter to avoid empty-diff false-skips on squash merges.

## Consequences

- Governance Phase 0 always runs (no path gate)
- Phase 1 compute skipped on doc/infra-only commits; savings ~2–4 min per run
- `validate-aggregate.sh` updated to accept `skipped` result
- Renovate version bumps to `dorny/paths-filter` handled automatically
