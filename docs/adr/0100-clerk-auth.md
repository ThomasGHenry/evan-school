---
status: superseded
date: 2026-08-23
tags: [architecture, tooling]
implementation: apps/web/src/middleware.ts
superseded-by: 0108-payload-cms-auth.md
---

# 0100. Clerk as Auth Provider

## Context

PRD §11 Q1 identified auth library choice as a blocker before any Phase 1 build.
Three options were evaluated: BetterAuth, Supabase Auth, and Clerk.

The site requires four access tiers (Anonymous, Mailing List Member, Paid Student,
Admin) with per-course enrollment scoping. Middleware must protect `/dashboard`,
`/courses/[slug]/content`, `/resources`, `/account`, and `/admin` routes.

ADR 0024 in the template documents Clerk as the default recommendation based on
BLM's prior evaluation of Auth.js and Better Auth.

## Decision

Clerk. `clerkMiddleware` with `createRouteMatcher` protects the five route families
listed above. Public routes (landing page, blog, course marketing pages, checkout,
login, signup) pass through without auth checks.

Course-level access scoping (Tier 2 students can only see courses they paid for)
is enforced at the database layer via `Enrollment.accessGranted`, not in middleware.
Middleware gates authentication; route handlers gate authorization.

## Consequences

- `@clerk/nextjs` added to `apps/web` dependencies
- `NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY` and `CLERK_SECRET_KEY` added to env schema
  in `packages/config/src/index.ts`
- `apps/web/src/middleware.ts` replaced from passthrough stub to Clerk middleware
- `apps/web/src/app/layout.tsx` wraps the app in `<ClerkProvider>`
- Clerk manages session tokens; our DB stores `User.role` for tier enforcement
- Magic link and OAuth (Google) are Clerk features available with zero extra code
  when needed — deferred to post-MVP per PRD §6.8
