---
status: accepted
date: 2026-08-28
tags: [tooling, analytics]
implementation: apps/web/src/app/layout.tsx
supersedes: 0107-posthog-analytics.md
---

# 0119. Analytics: PostHog + GA4 with split responsibilities

## Context

ADR 0107 adopted PostHog as the sole analytics tool. seo.md §51 recommends GA4
for search performance and AI referral measurement, citing `utm_source=chatgpt.com`
as a specific tracking requirement and listing `NEXT_PUBLIC_GA_ID` as the only
analytics public env var in the env schema.

The two tools cover different questions:

**PostHog** — product analytics, session replay, cross-session identity. Answers:
where do visitors drop in the checkout flow, what did a user do across sessions
before enrolling, which elements do users interact with on the landing page.
PostHog `posthog.identify()` integrates with Payload auth — when a visitor
authenticates, their full journey resolves across sessions. Session replay on
non-sensitive pages provides direct UX debugging capability.

**GA4** — search performance and acquisition measurement. Answers: which guides
drive organic traffic, how many sessions originate from ChatGPT
(`utm_source=chatgpt.com`), what is the conversion path from AI referral to
consultation booking. GSC links natively to GA4, making the four-layer analytics
view (GSC + GA4 + Vercel Analytics + AI referral) coherent in one interface.

Neither tool alone covers both questions. Running both is the correct answer.

## Decision

PostHog and GA4 run in parallel with non-overlapping event responsibilities.

**PostHog owns (product analytics):**
- `consultation_cta_clicked` (source: landing, course page, the-work page)
- `newsletter_submitted`
- `checkout_initiated` (course slug in properties)
- `checkout_completed` (course slug, amount)
- `course_content_viewed` (course slug, section)
- `dashboard_viewed`
- `audio_play`, `audio_25_percent`, `audio_50_percent`, `audio_completed`
- `article_view` (guide slug)
- `article_to_work_clicked`
- Session replay enabled on all non-sensitive pages
- Session replay disabled on: `/contact`, `/checkout`, `/account`, `/login`,
  `/signup`, `/reset-password`
- All form fields redacted in PostHog session replay

**GA4 owns (search and acquisition):**
- Page view tracking (all public routes)
- UTM parameter capture — specifically `utm_source=chatgpt.com` for AI referral
- Acquisition → landing page report
- GSC integration (organic search performance)
- `consultation_click` (mirrors PostHog event for cross-tool verification)
- `contact_submit`
- `event_registration_click`
- `course_interest_click`
- `external_authority_click`

**No duplicate `pageview` events** — GA4 handles page views via its native
measurement; PostHog page views are disabled to avoid double-counting.

## Consequences

- `NEXT_PUBLIC_POSTHOG_KEY`, `NEXT_PUBLIC_POSTHOG_HOST` retained in env schema
- `NEXT_PUBLIC_GA_ID` added to env schema in `packages/config/src/index.ts`
- Both providers initialised in `apps/web/src/app/layout.tsx`
- PostHog `capture_pageview: false` to prevent double-counting with GA4
- PostHog session replay configured with form field redaction
- Cookie consent banner required before either tool fires — deferred to
  pre-launch review (GDPR jurisdiction TBD)
- ADR 0107 superseded by this decision
- GitHub issue #26 (analytics decision) closed
- GitHub issue #46 (GA4 integration) tracks implementation
