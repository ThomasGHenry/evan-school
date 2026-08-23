---
status: accepted
date: 2026-07-07
tags: [architecture, tooling]
implementation: apps/web/src/middleware.ts
---

# 0024. Clerk as Default Auth Provider

## Context

The template ships an auth middleware slot in `apps/web/src/middleware.ts`. Without
a default, instances must wire auth from scratch on first use. BLM (the first instance)
converged on Clerk after evaluating Auth.js and Better Auth.

## Decision

The template ships a passthrough `middleware.ts` stub. Instances replace it with their
auth provider of choice. Clerk is the documented default recommendation based on BLM's
experience: JWT-native, Next.js App Router compatible, generous free tier, minimal
configuration.

## Consequences

- Template remains auth-agnostic — the stub passes all requests, nothing breaks on
  instantiation before auth is wired
- Instances swap the stub for their provider's middleware (one file, one export)
- Clerk-specific patterns (allowlist, session claims) live in instances, not the template
