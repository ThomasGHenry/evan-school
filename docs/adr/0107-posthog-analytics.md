---
status: superseded
date: 2026-08-25
tags: [tooling, analytics]
implementation: apps/web/src/app/layout.tsx
superseded-by: 0119-analytics-posthog-ga4.md
---

# 0107. PostHog for product analytics

## Context

PRD §11 Q3 left analytics open between Plausible (privacy-first, paid, lightweight),
PostHog (product analytics, generous free tier), and GA4 (free, heavy, privacy concerns).

The site needs more than page-view counts: conversion funnel visibility (visitor →
subscriber → student), event tracking (mailing list CTA clicks, checkout initiated,
checkout completed, course content views), and session recording for UX debugging.
Plausible covers traffic but not product analytics. GA4 introduces GDPR complexity
and cookie consent overhead.

## Decision

PostHog. Self-hosted is not required — PostHog Cloud free tier (1M events/month)
is sufficient for current scale.

Key events to instrument from Phase 1:
- `mailing_list_cta_clicked`
- `checkout_initiated` (course slug in properties)
- `checkout_completed` (course slug, amount)
- `course_content_viewed` (course slug, section)
- `dashboard_viewed`

## Consequences

- PostHog JS snippet added to `apps/web/src/app/layout.tsx` via
  `<PostHogProvider>` (React provider pattern)
- `NEXT_PUBLIC_POSTHOG_KEY` and `NEXT_PUBLIC_POSTHOG_HOST` added to env schema
- Cookie consent banner may be required depending on jurisdiction — deferred to
  pre-launch review
- PRD §11 Q3 closed; PRD §8 tech stack row updated
- Plausible and GA4 not implemented
