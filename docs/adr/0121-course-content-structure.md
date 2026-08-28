---
status: proposed
date: 2026-08-28
tags: [architecture, routing]
implementation: apps/web/src/app/courses/[slug]/content/page.tsx
---

# 0121. Course content page structure

## Context

`/courses/[slug]/content` surfaces five ordered sections to enrolled students:
Intro document, Setting the stage, Zoom link, Recording link, and Meditation /
supplementary resources. The question is whether these sections are all rendered
on a single route or addressed via separate sub-routes (e.g.
`/courses/[slug]/content/recording`).

## Decision

Single route. All sections rendered on one page at `/courses/[slug]/content`.

Section ordering is driven by a `ContentSection` enum in the data model. The
enum's sort order determines render order — no separate routing needed to
control sequence.

Rationale:
- Content is gated — anonymous crawlers never reach it, so there is no SEO
  benefit to separately addressable sub-routes.
- Auth is simpler: one route, one access check (Payload access control on the
  `Course` collection verifies active `Enrollment` row).
- Data model is simpler: `course_content.sort_order` (integer) + `section`
  (enum) is sufficient without a routing hierarchy.
- Future tab navigation or anchor links can be added without a route change.

## Consequences

- `apps/web/src/app/courses/[slug]/content/page.tsx` is the sole route
- Payload `CourseContent` collection has `section: ContentSection` enum and
  `sort_order: number` fields
- No sub-routing introduced; anchor links (`#intro`, `#zoom-link`, etc.) may be
  added in a later iteration without requiring an ADR revision
- If per-section deep-linking becomes a product requirement, this decision should
  be revisited
