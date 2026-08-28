---
status: proposed
date: 2026-08-28
tags: [architecture, auth, seo]
implementation: apps/web/src/app/resources/page.tsx
---

# 0122. Resources index visibility

## Context

The `/resources` collection contains a mix of public resources (e.g.
`/resources/introductory-ipf-practice`) and subscriber-gated resources. PRD §5
already distinguishes these with separate access tiers. The question is whether
the index page at `/resources` is publicly visible, or also gated to
subscribers.

## Decision

Public index, gated detail.

- `/resources` index: PUBLIC — lists all resources (titles, descriptions, access
  tier badge) regardless of whether the visitor is authenticated. Fully
  crawlable and indexable.
- `/resources/[slug]` detail: access determined by `Resource.isPublic` field
  (Payload collection field, see ADR 0108).
  - `isPublic: true` → renders freely to all visitors.
  - `isPublic: false` → requires SUBSCRIBER+ auth. Unauthenticated visitors are
    redirected to `/login`.

Rationale:
- Resource titles and descriptions are indexable metadata — they improve SEO and
  GEO surface area for the site. Gating the index provides no security benefit;
  the content itself is still protected at the detail route.
- The public index acts as a catalogue that motivates subscription: visitors can
  see what they're missing before they sign up.
- Consistent with the pattern already established for course marketing pages
  (public index, gated content).

## Consequences

- `apps/web/src/app/resources/page.tsx` is public — no auth middleware check
- `apps/web/src/app/resources/[slug]/page.tsx` checks `Resource.isPublic` and
  redirects to `/login` for unauthenticated visitors on gated resources
- Payload `Resource` collection requires an `isPublic: boolean` field
- The index page may show an access tier badge ("Free" / "Subscriber") to
  communicate gating without surprising visitors at the detail route
- PRD §6.3 describes gated resources; this ADR clarifies that the index itself
  is not gated
