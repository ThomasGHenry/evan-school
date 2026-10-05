# EvanLeed.com — Product Requirements Document

**Version:** 0.3
**Date:** 28 August 2026
**Status:** Draft — stack settled, design complete, pre-build
**Authors:** Evan (product), Thomas (engineering)
**Reference aesthetic:** [thefield.us](https://thefield.us)

---

## Table of Contents

1. [Overview](#1-overview)
2. [Goals & Non-Goals](#2-goals--non-goals)
3. [User Roles & Access Control](#3-user-roles--access-control)
4. [Visitor Journey](#4-visitor-journey)
5. [Site Map & Page Inventory](#5-site-map--page-inventory)
6. [Feature Requirements](#6-feature-requirements)
7. [Content Architecture](#7-content-architecture)
8. [Tech Stack](#8-tech-stack)
9. [Integrations](#9-integrations)
10. [Build Phases](#10-build-phases)
11. [Open Questions](#11-open-questions)
12. [Out of Scope (MVP)](#12-out-of-scope-mvp)

---

## 1. Overview

A new website for Evan Leed's IPF facilitation practice, replacing the current Squarespace setup. The site serves three jobs simultaneously: inbound discovery (SEO/GEO), consultation booking (primary conversion), and course delivery (paid student experience). These map directly to top-of-funnel, middle-funnel, and bottom-of-funnel, and will be built in that order of leverage — SEO foundation first, enrollment later.

The current workflow — manual payment → manual email → password-protected Squarespace page → Zoom session → Zoom recording — will be automated and made scalable, while keeping the near-term architecture deliberately simple.

---

## 2. Goals & Non-Goals

### Goals

- **Discoverability.** Rank in Google, appear in AI-generated answers (ChatGPT, Perplexity, etc.), surface in referrals. Displace a fraudulent incumbent currently ranking for IPF Protocol content.
- **Consultation booking.** Free consultation via Calendly is the primary conversion goal. This is the hero CTA on the landing page.
- **Audience capture.** Mailing list growth is the secondary conversion goal. The list is the nurture funnel.
- **Course sales.** Self-serve enrollment, payment, and access provisioning — no manual steps for Evan.
- **Student experience.** A clean, persistent home for course materials before and after each live session.
- **Admin control.** Evan can manage content without a developer from Phase 1 (Payload CMS admin panel).
- **Performance.** Static-first rendering for public pages; fast, lightweight, no heavy media on the landing page at MVP.

### Non-Goals (MVP)

- Video hosting / embedded media players (Zoom recording links suffice for now)
- Student community or forums
- Subscription / recurring billing
- Mobile app
- Live chat or support tooling
- A/B testing infrastructure

---

## 3. User Roles & Access Control

Four tiers, each inheriting access from the tier below it.

### Tier 0 — Anonymous Visitor

Anyone arriving from Google, ChatGPT, social, or direct link.

**Can access:**
- Landing page
- Guides / free articles
- Course marketing pages
- Event pages
- Checkout flow (to enroll)
- Login / signup pages

**Cannot access:** protected resources, course content, student dashboard, admin

---

### Tier 1 — Mailing List Member (Subscriber)

Subscribed via MailChimp. Has an account (created when they sign up or enroll). Has not necessarily paid.

**Can access:** everything above, plus:
- Subscriber-tier resources (`/resources/*` items with `access: subscriber`)
- Account settings

Subscriber access requires BOTH a signed-in account AND an active MailChimp subscription. Unsubscribing removes subscriber-tier access, including for paid students (their paid entitlements are unaffected). ADR 0125.

**Cannot access:** course content, student dashboard (unless also enrolled), admin

> **Decision (2026-08-28):** Subscriber tier is retained. The protected free content at `/resources` is the mailing list incentive — subscribing unlocks it. This is a deliberate conversion mechanism. Account creation friction is accepted.

---

### Tier 2 — Paid Student

Holds at least one entitlement: membership of a specific class cohort (e.g. Fall 2026 *Attachment and the Best Self*) or a purchased standalone product. Access is scoped per cohort or product — an entitlement for one does not unlock another. Entitlements never expire and are additive: a repeat student keeps every cohort's materials. ADR 0125.

**Can access:** everything above, plus:
- Course content for each cohort they belong to (`/courses/[slug]/content`)
- Purchased products
- Student dashboard (`/dashboard`)

**Cannot access:** other students' courses, admin

---

### Tier 3 — Admin

Evan (and any future collaborators he designates).

**Can access:** everything, plus:
- Payload CMS admin panel for courses, guides, events, protected resources
- User management (assign / revoke access, view enrollment status)

---

## 4. Visitor Journey

```
1. DISCOVERY
   Google / ChatGPT / referral / social
   → landing page or guide article or course page

2. BROWSE
   Free guides, about section, course catalog, event listings
   [ Tier: Anonymous ]

3. CONSULT  ← Primary CTA on landing page
   Book free consultation via Calendly
   → 30-minute call with Evan
   [ Tier: Anonymous ]

4. SUBSCRIBE  ← Secondary CTA on landing page
   Mailing list signup
   → MailChimp welcome sequence triggers
   → Access to protected resources unlocked
   [ Tier: Anonymous → Mailing List ]

5. NURTURE
   MailChimp drip sequences
   Access to protected resources (/resources)
   Course teasers, social proof, scheduling nudges
   [ Tier: Mailing List ]

6. ENROLL  ← Bottom of funnel
   Course marketing page → Checkout
   → Payment (Stripe)
   → Account auto-created (or linked if existing)
   → Course access provisioned immediately
   → Confirmation email sent
   [ Tier: Mailing List → Paid Student ]

7. PRE-COURSE
   Student dashboard: intro document, "setting the stage" materials
   Available from enrollment date through course end and beyond
   [ Tier: Paid Student ]

8. LIVE COURSE
   Zoom link surfaced in dashboard at scheduled time
   [ Tier: Paid Student ]

9. POST-COURSE
   Zoom recording link appears in dashboard (Evan adds manually for MVP)
   All pre-course materials remain accessible
   [ Tier: Paid Student ]

10. RE-ENGAGE
    MailChimp → next course, community teaser (future)
    [ Tier: Paid Student ]
```

---

## 5. Site Map & Page Inventory

Access tier shown in brackets: `[P]` Public · `[M]` Mailing List · `[S]` Paid Student · `[A]` Admin

```
/                                        [P]  Landing page
/about                                   [P]  About Evan
/the-work                                [P]  The work — IPF facilitation, 1:1 sessions
/who-this-is-for                         [P]  Audience fit
/ideal-parent-figure-protocol            [P]  Flagship SEO/GEO hub — IPF explainer
/scope-and-safety                        [P]  Scope statement and safety information
/privacy                                 [P]  Privacy policy
/contact                                 [P]  Contact

/guides                                  [P]  Guides index (SEO/GEO content)
/guides/[slug]                           [P]  Individual guide

/events                                  [P]  Events index
/ipf-weekend-retreat                     [P]  Event page (top-level, not /events/[slug])

/courses/i-can-relate                    [P]  Course marketing page
/courses/[slug]/content                  [S]  Course content (paid, per-cohort scoped)

/resources                               [P]  Public catalogue of all tiers (badge + teaser)
/resources/introductory-ipf-practice     [P]  Free public resource (no auth gate)
/resources/[slug]                        [P/M/S]  Item gated by its access tier (ADR 0125)

/dashboard                               [S]  Student dashboard
/checkout                                [P]  Checkout
/checkout/success                        [P]  Payment confirmation — NOINDEX
/account                                 [M]  Account settings
/login                                   [P]  Login
/signup                                  [P]  Signup
/reset-password                          [P]  Password reset

/admin                                   [A]  Admin home (Payload admin UI)
/admin/courses                           [A]  Manage courses
/admin/guides                            [A]  Manage guides
/admin/resources                         [A]  Manage resources
/admin/users                             [A]  User management
```

**Legacy redirect:**
```
/relationship-course-summer-2026  →  /courses/i-can-relate  (308)
```

---

## 6. Feature Requirements

### 6.1 Landing Page (`/`)

- **Primary CTA:** consultation booking via Calendly link. This is the hero action — large, prominent, above the fold.
- **Secondary CTA:** mailing list email signup (MailChimp). Present and visible, but not the hero.
- About / intro section linking to `/about`.
- Course and event listings visible but secondary.
- No heavy media at MVP. Landing page must stay lightweight for SEO.
- Standard footer: links, social, legal.

### 6.2 Guides (`/guides`, `/guides/[slug]`)

- SEO and GEO-optimized articles answering common IPF and attachment-related questions.
- Fully public and crawlable. All standard SEO metadata: title, description, OpenGraph, JSON-LD `Article` schema, canonical URLs.
- Searchable / filterable index page.
- Individual guide pages (`/guides/[slug]`) statically generated at build time.
- Evan creates and publishes guides via Payload CMS admin panel.
- Publication cadence: 1 guide per week over 11 weeks (not all at launch).

### 6.3 Resources Catalogue (`/resources`)

- Index page is PUBLIC and crawlable: lists resources of every tier with an access badge and a teaser description (ADR 0125, superseding ADR 0122).
- Each resource carries an access tier: `public` (renders to everyone, indexable), `subscriber` (signed-in + active MailChimp subscription), or `paid` (entitlement for the referenced cohort or product).
- Item pages (`/resources/[slug]`) render the content, a sign-up prompt, or a purchase prompt according to the visitor's access.
- Subscriber-tier content — audio, PDFs, guided meditations — is the mailing-list lead magnet.
- Evan manages via Payload CMS admin panel.

### 6.4 Course Marketing Pages (`/courses`, `/courses/[slug]`)

- Fully public and crawlable.
- Per-course page: description, Evan's background for this course, schedule/date, price, enroll CTA → checkout.
- Course catalog page lists all active courses.
- Statically generated for SEO. Content managed by Evan via Payload CMS admin panel.

### 6.5 Course Content (`/courses/[slug]/content`)

Paid students only, scoped to the cohort(s) they hold entitlements for. Access is permanent (ADR 0125).

**Content structure per cohort:**

| Section | Timing | Notes |
|---|---|---|
| Intro document | From enrollment | Overview, what to expect |
| Setting the stage | From enrollment | Pre-reading, framing materials |
| Zoom link (live session) | Shown at course time | Evan provides link, surfaces in dashboard |
| Recording link | After live session | Evan adds post-session; links to Zoom cloud recording |
| Meditation links / resources | Ongoing | Supplementary materials |

Evan updates content via Payload CMS admin panel.

### 6.6 Student Dashboard (`/dashboard`)

- Authenticated, paid students only.
- Lists all courses the student is enrolled in (left nav or card grid).
- Clicking a course opens that course's content view.
- Shows course status: upcoming / live / completed.
- MVP: simple, functional. No progress tracking, no completion markers yet.

### 6.7 Checkout & Enrollment (`/checkout`)

- Triggered from a course (cohort) marketing page CTA or a product page CTA.
- Payment: Stripe. `payment_intent.succeeded` webhook provisions access, idempotent on the Stripe event id.
- On successful payment, inside one Payload transaction (ADR 0125):
  - Account created (or existing account linked)
  - Permanent Entitlement created for the purchased cohort or product
  - Student added to MailChimp "paid students" segment
  - Confirmation email sent (via MailChimp or transactional email)
- No subscription billing. Single-transaction purchases only.
- At launch, one placeholder product is live and visible to exercise the purchase → entitlement flow and gather feedback.

### 6.8 Auth Pages

- Login, signup, password reset — custom Next.js pages backed by Payload REST auth endpoints.
- Signup is triggered both from the mailing list CTA (Tier 1 account) and from checkout (Tier 2 account).
- Standard flow: email + password. Magic link or OAuth (Google) are nice-to-have, not MVP.

### 6.9 Admin CMS (`/admin`)

Payload CMS auto-generated admin panel — available from Phase 1. Evan can manage content without a developer from day one.

**Collections:** Guides, Courses, Events, Resources, Users.
**Admin/courses:** create/edit course records, attach content sections, set Zoom link + recording URL, publish/unpublish.
**Admin/guides:** create/edit/publish guide articles, set metadata.
**Admin/resources:** create/edit protected content items, attach files or links.
**Admin/users:** view all users, see enrollment status and mailing list tier, manually assign or revoke course access (for edge cases like refunds or comps).

---

## 7. Content Architecture

### Public content (no auth)
- Landing page copy
- Guide articles
- Course marketing copy
- Event listings
- `/ideal-parent-figure-protocol` flagship hub

### Subscriber content (mailing list tier)
- Audio recordings, PDFs, guided meditations offered as list incentives
- Listed publicly with a teaser; content requires a signed-in account with an active subscription

### Paid content (entitlement tier, per cohort or product)
- Cohort materials: intro doc, setting the stage, Zoom link, recording link, meditation resources
- Standalone products
- Scoped: a student only sees cohorts and products they hold entitlements for; entitlements are permanent

### Admin-managed
- All of the above, editable via Payload CMS admin panel
- User roster and access assignments

### MailChimp segments
- `subscribers` — mailing list, not enrolled
- `students-[course-slug]` — paid, enrolled in a specific course
- `students-all` — anyone who has ever purchased

---

## 8. Tech Stack

| Layer | Choice | Status | Notes |
|---|---|---|---|
| Frontend framework | Next.js (App Router) | Settled | SSG for public pages (SEO), SSR for auth routes. |
| Hosting | Vercel | Settled | Native Next.js integration, edge CDN, CI/CD. |
| Database | PostgreSQL (Neon) | Settled | Neon chosen for copy-on-write branching — instant prod-data clone per PR for migration rehearsal. Audit pricing cliff before launch (§11 Q5). |
| Data model / ORM | Payload CMS (`@payloadcms/db-postgres`) | Settled | ADR 0125. Payload is the sole schema and migration owner; no Prisma. Drizzle available via the adapter for raw queries. |
| Authentication | Payload CMS | Settled | ADR 0108. Payload Users collection with role field. `payload-token` cookie in middleware. Single source of truth — no Clerk/DB sync. |
| Payments | Stripe | Settled | ADR 0106. `payment_intent.succeeded` webhook provisions enrollment. No PayPal. |
| Email / CRM | MailChimp (existing) | Settled | Keep existing account. Segment by tier. Drip and upsell sequences. |
| Analytics | PostHog + GA4 | Settled | ADR 0119. PostHog: product analytics, session replay, cross-session identity. GA4: search performance, AI referral tracking (`utm_source=chatgpt.com`). |
| SEO / GEO | Next.js metadata API | Settled | `robots.ts` (generated), `sitemap.ts` (dynamic), OpenGraph, JSON-LD. `llms.txt` not implemented (ADR 0111). |
| CMS (content) | Payload CMS | Settled | ADR 0108. Auto-generated admin panel available Phase 1. Evan edits without a developer from day one. |
| Community | Circle.so or custom | Future | Not in MVP. |

### Payload collections (sketch — ADR 0125)

```
users           email, role, mailchimp_id, subscription_status
courses         slug, title, description, status, published_at
cohorts         course, label, starts_at, ends_at, zoom_link
products        slug, title, description, price_ref, status
entitlements    user, cohort | product, granted_at, stripe_event_id  (permanent, additive)
course_content  cohort, section (enum), content_type, content_url, sort_order, access
guides          slug, title, body, direct_answer, published_at, seo_meta
resources       slug, title, teaser, content_type, content_url, access, cohort | product, published_at
events          slug, title, description, starts_at, ends_at, status, published_at
```

---

## 9. Integrations

| Service | Purpose | Trigger |
|---|---|---|
| Calendly | Free consultation booking | Primary CTA on landing page and `/the-work` |
| MailChimp | Mailing list, drip sequences, student segments | Signup form → subscribe. Payment success → add to student segment. |
| Stripe | Payment processing | `payment_intent.succeeded` webhook → provision enrollment row |
| Zoom | Live session delivery + recording | Evan manages externally; URL stored in DB and surfaced to students |
| PostHog | Product analytics, session replay | Funnel events: consultation click, checkout, course views |
| GA4 | Search and AI referral measurement | Page views, UTM capture, GSC integration |

---

## 10. Build Phases

Ordered by SEO foundation first, enrollment later. Phase ordering follows seo.md.

### Phase 1 — Foundation (SEO + infrastructure)

*Outcome: site is live, indexed, discoverable, and Evan can manage content.*

- Payload CMS installed: Users collection, auth middleware, admin panel
- `robots.ts` (generated), `sitemap.ts` (dynamic with `lastModified`)
- Canonical URL normalization: apex → www 308, no trailing slash (ADR 0109)
- GA4 + PostHog integrated
- `BusinessSettings` central config (ADR 0112)
- JSON-LD: `WebSite` + `Person` entity (`/#evan-leed`) on landing page
- Landing page with consultation CTA (Calendly) + newsletter signup (secondary)
- Performance budget CI gate (LCP p75 < 2.5s, JS < 150KB)

### Phase 2 — Migration-critical pages (before DNS cutover)

*Outcome: every legacy Squarespace URL is accounted for; site can safely replace the old one.*

- Legacy URL inventory + redirect manifest (ADR 0110, issue #50)
- `/the-work`, `/about`, `/contact`, `/who-this-is-for`, `/scope-and-safety`
- `/ideal-parent-figure-protocol` (flagship SEO/GEO hub)
- JSON-LD: `Service`, `ProfilePage`, `ContactPage`, `BreadcrumbList` per page type
- OG image system (dynamic 1200×630 per page)
- Security headers: HSTS, nosniff, Referrer-Policy, CSP report-only (ADR 0115)

### Phase 3 — Content machine

*Outcome: inbound content engine is running; mailing list members have a reason to stay.*

- `/guides` listing + `/guides/[slug]` detail pages
- Guide publication cadence: 1/week over 11 weeks (not all at launch)
- IndexNow integration: CMS publish → immediate index ping (ADR 0114)
- `/resources` (protected, mailing list auth-gated)
- Guides JSON-LD: `Article` with `/#evan-leed` author entity
- MailChimp subscribe form wired to Payload Users collection

### Phase 4 — Events + courses (public marketing)

*Outcome: event and course discovery pages are live and indexed.*

- `/events`, `/events/[slug]` with event state machine + expiry automation (ADR 0118)
- `/courses`, `/courses/[slug]` course marketing pages
- Course JSON-LD: `Course` schema (name, provider, description, price, startDate)
- `CollectionPage` JSON-LD on `/events` and `/courses`

### Phase 5 — Enrollment + student experience

*Outcome: a stranger can pay for a course and immediately access their content.*

- Checkout (Stripe) + enrollment provisioning via `payment_intent.succeeded` webhook
- Student dashboard (`/dashboard`)
- Course content pages (`/courses/[slug]/content`) — Payload access control enforcement
- Auth pages: `/login`, `/signup`, `/reset-password`
- MailChimp webhook: enroll → add to student segment
- Backfill script: seed enrollment records for existing Squarespace-era students

### Phase 6 — Admin operations

*Outcome: Evan manages all content and users without developer involvement.*

- Payload admin: course content CRUD (Zoom links, recording URLs, section ordering)
- User management via Payload admin (assign/revoke access, view roster)
- MailChimp segment automation refinement

### Phase 7 — Polish

*Outcome: richer student and community experience.*

- Hosted video / embedded player (replace raw Zoom recording links — Mux or Cloudflare Stream)
- Student community consideration (Circle.so integration or custom)
- Progress tracking, bookmarking, completion markers
- Course gifting, discount codes, promo codes
- Student profiles

---

## 11. Open Questions

| # | Question | Owner | Priority |
|---|---|---|---|
| 1 | ~~**Auth library choice**~~ — **Closed.** Payload CMS. ADR 0108. | — | ~~Blocker~~ |
| 2 | ~~**Mailing list auth tier**~~ — **Closed.** Subscriber tier retained. `/resources` is the mailing list incentive. Account creation friction is accepted. 2026-08-28. | — | ~~Phase 1~~ |
| 3 | ~~**Analytics choice**~~ — **Closed.** PostHog + GA4. ADR 0119. | — | ~~Phase 1~~ |
| 4 | ~~**About / Contact**~~ — **Closed.** Separate pages: `/about` and `/contact`. 2026-08-28. | — | ~~Design phase~~ |
| 5 | **Pricing cliff audit** — Check Neon free tier limits and the cost at the next tier before launching. | Thomas | Pre-launch |
| 6 | ~~**PayPal → Stripe migration timing**~~ — **Closed.** Stripe from Phase 1. No PayPal. ADR 0106. | — | ~~Phase 1 review~~ |
| 7 | **Recording hosting long-term** — Zoom cloud recordings expire or have storage limits. When do we migrate to hosted video (Mux, Cloudflare Stream, Vimeo)? | Thomas | Phase 7 |

---

## 12. Out of Scope (MVP)

- Video hosting / embedded media player (Zoom links suffice)
- Student community or forums
- Subscription / recurring billing
- Course gifting, discount codes, promo codes
- Mobile app
- Live chat or support tooling
- A/B testing
- Internationalization / multi-language
- Affiliate or referral programs
- Certificate of completion
- Course ratings or reviews
- Student-to-student messaging

---

## Next Steps

1. **Owner decisions** — Evan to confirm Calendly URL, session price, sliding scale, scope statement wording (blocks issue #48 / ADR 0112).
2. **Phase 1 build** — install Payload CMS, configure Users collection, wire middleware (issue #3).
3. **Neon pricing audit** (§11 Q5) — confirm free tier headroom before launch.
