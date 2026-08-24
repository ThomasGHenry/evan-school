---
status: accepted
date: 2026-08-24
tags: [architecture, tooling]
implementation: apps/web/src/lib/ability.ts
---

# 0101. RBAC Pattern: CASL + Three-Layer Enforcement

## Context

PRD §3 defines four access tiers in a flat inheritance hierarchy:

| Tier | Role constant | Gated routes |
|------|--------------|--------------|
| 0 | Anonymous | — (public) |
| 1 | `SUBSCRIBER` | `/resources/*` |
| 2 | `STUDENT` | `/dashboard`, `/account`, `/courses/[slug]/content` |
| 3 | `ADMIN` | `/admin/*` |

Course content is additionally scoped per-enrollment: a STUDENT may only access
courses they have paid for. This is a resource-level check beyond role alone.

Two options were considered:

**Raw role checks** — `if (user.role !== 'ADMIN') redirect(...)` scattered at each
route. Low setup cost. Becomes brittle as roles and resources multiply: every new
permission requires finding and updating multiple callsites. No single source of truth.

**CASL** — isomorphic JS authorization library. Centralises all permission rules in
one `defineAbilitiesFor(user)` factory. Works identically on server (Server
Components, API routes, Server Actions) and client (conditional UI rendering). Adding
or changing a permission is a one-line edit in the factory, not a grep-and-replace.

## Decision

CASL (`@casl/ability`) with a three-layer enforcement pattern:

1. **Edge middleware** (Clerk) — authentication only. Is the user signed in? If not,
   redirect to `/login`. Does not check role. Fast, broad.

2. **Server layout / Server Component** — role check via `ability.can('read', route)`.
   Redirects or returns 403 for mismatched tier. Runs per-request on the server.

3. **API route / Server Action** — last-line defence before any mutation or data
   read. Re-derives ability from the session; never trusts client-supplied role.

`defineAbilitiesFor(user: User)` is the single source of truth. All three layers
call it. Course-level enrollment scoping is expressed as a CASL condition:
`can('read', 'CourseContent', { enrollments: { some: { userId: user.id } } })`.

## Consequences

- `@casl/ability` and `@casl/react` added to `apps/web` dependencies
- `apps/web/src/lib/ability.ts` — `defineAbilitiesFor` factory (server + client safe)
- `apps/web/src/lib/require-ability.ts` — server util that throws or redirects on
  `cannot(...)`; used in layouts and API handlers
- New permission rules require one edit in `ability.ts`, not scattered callsites
- Client components can call `useAbility()` to show/hide UI elements without
  duplicating role logic
- When Evan needs collaborator roles with narrower admin scopes (e.g. blog-editor
  cannot touch enrollments), the factory extends naturally without structural change
- CASL does not replace Clerk session management; it only interprets the role stored
  in `User.role` (Neon) and synced to Clerk `publicMetadata`
