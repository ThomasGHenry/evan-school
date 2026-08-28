---
status: accepted
date: 2026-08-28
tags: [architecture, tooling, cms, auth]
implementation: apps/web/payload.config.ts
supersedes: 0100-clerk-auth.md
---

# 0108. Payload CMS as content system and auth provider

## Context

Two separate decisions required reconciliation before Phase 1 build:

**Auth:** ADR 0100 adopted Clerk as the auth provider. Clerk maintains identity
in its own hosted system; the local DB stores a `User` row synced via webhook.
This creates two sources of truth. If the webhook fails, the DB has no user
record — a known failure mode requiring defensive handling throughout the
application. Per-course enrollment scoping (Student A cannot see Course B) is
enforced in route handlers, not at the data layer, so a missed `auth()` check
in any route is a data exposure bug.

**CMS:** ADR 0103 adopted a gray-matter interim content pipeline for MVP, with a
custom Payload admin planned for Phase 3. This means Evan cannot edit content
without a developer until Phase 3 ships.

Payload CMS v3 resolves both. It installs directly into the Next.js app — same
repo, same process, same Postgres database. It ships production-grade auth
(email/password, JWT, role-based access, password reset) co-located with the
content and enrollment data. RBAC is enforced via access control functions on
collections, evaluated at the data layer before any response is returned.

## Decision

Payload CMS v3 replaces Clerk (ADR 0100) and the gray-matter interim pipeline
(ADR 0103) in a single system.

**Payload handles:**
- Content management: Guides, Courses, Events, Resources collections
- Authentication: Users collection with `role` field
- RBAC: collection-level and document-level access control functions
- Admin UI: auto-generated, available at `/admin` to Admin-role users

**Auth tier mapping:**

| Role | Value | Access |
|---|---|---|
| Anonymous | no `req.user` | Public routes only |
| Subscriber | `subscriber` | Public + `/resources` |
| Student | `student` | Public + `/resources` + enrolled courses |
| Admin | `admin` | Everything |

**Per-course enrollment scoping** is enforced via a Payload access control
function on the `CourseContent` collection. The function returns false if no
`req.user`, true if `req.user.role === 'admin'`, and otherwise queries
`Enrollment` for `{ userId: req.user.id, courseId, accessGranted: true }`.
Payload translates this into a WHERE clause. Unauthorized access is rejected at
the data layer regardless of which route surfaces the data.

**Auth routes:** `/login`, `/signup`, `/reset-password` are custom Next.js pages
calling Payload's REST auth endpoints (`/api/users/login`,
`/api/users/forgot-password`, `/api/users/reset-password`).

**Middleware:** `apps/web/src/middleware.ts` checks for the `payload-token` cookie
on protected routes and redirects to `/login?redirect=<path>` if absent. Token
validity is verified by Payload's local API in server components and route
handlers.

**Payload auth uses `payload-token` cookie (HTTP-only JWT).** The frontend never
handles raw tokens.

OAuth (Google) and magic links are Payload plugin features, deferred to
post-MVP.

## Consequences

- `@clerk/nextjs` removed from `apps/web` dependencies
- `NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY` and `CLERK_SECRET_KEY` removed from env
  schema in `packages/config/src/index.ts`
- `PAYLOAD_SECRET` (minimum 32 characters, used for JWT signing) added to env
  schema
- `apps/web/payload.config.ts` created with Users, Guides, Courses, Events,
  Resources collections
- `apps/web/src/middleware.ts`: `clerkMiddleware` replaced with `payload-token`
  cookie check
- `apps/web/src/app/layout.tsx`: `<ClerkProvider>` removed
- Three auth pages to build: `/login`, `/signup`, `/reset-password`
- Social login (OAuth) is not a config toggle — requires Payload OAuth plugin
  when needed
- Gray-matter content pipeline (ADR 0103) is not implemented — Payload is the
  content system from Phase 1
- Custom admin UI (PRD §6.9 Phase 3 plan) is replaced by Payload's auto-generated
  admin panel
- ADR 0100 and ADR 0103 are superseded by this decision
