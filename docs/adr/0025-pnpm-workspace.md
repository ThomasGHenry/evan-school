---
status: accepted
date: 2026-07-07
tags: [tooling]
implementation: pnpm-workspace.yaml
---

# 0025. pnpm Workspace

## Context

The template shipped with npm workspaces. BLM (the first instance) migrated to pnpm
within the first week. NX monorepo + pnpm is the canonical combination: pnpm's strict
symlink model prevents phantom dependency bugs; NX's caching integrates cleanly with
pnpm's content-addressable store.

## Decision

Replace npm workspaces with pnpm workspaces (`pnpm-workspace.yaml`). Add `.npmrc` with
`shamefully-hoist=true` for NX module resolution compatibility. Require
`pnpm@10+` via `packageManager` field in root `package.json`.

## Consequences

- `pnpm install --frozen-lockfile` in CI; no `npm ci`
- `pnpm exec nx run-many -t <target>` replaces `npx nx run-many`
- Workspace dependencies must use `workspace:*` protocol in `package.json`
- `pnpm-lock.yaml` replaces `package-lock.json`
