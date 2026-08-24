# Evan's Meditation School — Product Requirements Document

**Version:** 0.1
**Date:** 22 August 2026
**Status:** Draft — pre-design, pre-stack-decision
**Authors:** Evan (product), Thomas (engineering)
**Reference aesthetic:** [thefield.us](https://thefield.us)

---

## Table of Contents

1. [Overview](#1-overview)
2. [Goals & Non-Goals](#2-goals--non-goals)
3. [User Roles & Access Control](#3-user-roles--access-control)
4. [Student Journey](#4-student-journey)
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

A new website for Evan's meditation school, replacing the current Squarespace setup. The site serves three jobs simultaneously: inbound discovery (SEO/GEO), audience capture (mailing list), and course delivery (paid student experience). These map directly to top-of-funnel, middle-funnel, and bottom-of-funnel, and will be built in that order of leverage.

The current workflow — PayPal payment → manual email → password-protected Squarespace page → Zoom session → Zoom recording — will be automated and made scalable, while keeping the near-term architecture deliberately simple.

---

## 2. Goals & Non-Goals

### Goals

- **Discoverability.** Rank in Google, appear in AI-generated answers (ChatGPT, Perplexity, etc.), surface in referrals.
- **Audience capture.** Mailing list growth is the primary conversion goal. The list is the funnel.
- **Course sales.** Self-serve enrollment, payment, and access provisioning — no manual steps for Evan.
- **Student experience.** A clean, persistent home for course materials before and after each live session.
- **Admin control.** Evan can manage content without a developer for day-to-day updates.
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
- Blog / free articles
- Course marketing pages
- Checkout flow (to enroll)
- Login / signup pages

**Cannot access:** protected resources, course content, student dashboard, admin

---

### Tier 1 — Mailing List Member

Subscribed via MailChimp. Has an account (created when they sign up or enroll). Has not necessarily paid.

**Can access:** everything above, plus:
- Protected resources (`/resources/*`)
- Account settings

**Cannot access:** course content, student dashboard (unless also enrolled), admin

> **Design note:** This tier requires authentication — an account — but no payment. The protected content is the incentive to subscribe. Whether this tier is worth the auth complexity is flagged as an open question (see §11).

---

### Tier 2 — Paid Student

Has purchased at least one course. Access is scoped per course — buying Course A does not unlock Course B.

**Can access:** everything above, plus:
- Course content for each course purchased (`/courses/[slug]/content`)
- Student dashboard (`/dashboard`)

**Cannot access:** other students' courses, admin

---

### Tier 3 — Admin

Evan (and any future collaborators he designates).

**Can access:** everything, plus:
- Admin CMS for courses, blog, protected resources
- User management (assign / revoke access, view enrollment status)

---

## 4. Student Journey

```
1. DISCOVERY
   Google / ChatGPT / referral / social
   → landing page or blog article or course page

2. BROWSE
   Free blog content, about section, course catalog
   [ Tier: Anonymous ]

3. SUBSCRIBE  ← Primary CTA on landing page
   Mailing list signup
   → MailChimp welcome sequence triggers
   [ Tier: Anonymous → Mailing List ]

4. NURTURE
   MailChimp drip sequences
   Access to protected resources (/resources)
   Course teasers, social proof, scheduling nudges
   [ Tier: Mailing List ]

5. ENROLL  ← Bottom of funnel
   Course marketing page → Checkout
   → Payment (PayPal MVP, Stripe target)
   → Account auto-created (or linked if existing)
   → Course access provisioned immediately
   → Confirmation email sent
   [ Tier: Mailing List → Paid Student ]

6. PRE-COURSE
   Student dashboard: intro document, "setting the stage" materials
   Available from enrollment date through course end and beyond
   [ Tier: Paid Student ]

7. LIVE COURSE
   Zoom link surfaced in dashboard at scheduled time
   [ Tier: Paid Student ]

8. POST-COURSE
   Zoom recording link appears in dashboard (Evan adds manually for MVP)
   All pre-course materials remain accessible
   [ Tier: Paid Student ]

9. RE-ENGAGE
   MailChimp → next course, community teaser (future)
   [ Tier: Paid Student ]
```

---

## 5. Site Map & Page Inventory

Access tier shown in brackets: `[P]` Public · `[M]` Mailing List · `[S]` Paid Student · `[A]` Admin

```
/                                   [P]  Landing page
/blog                               [P]  Free content / article index
/blog/[slug]                        [P]  Individual article
/resources                          [M]  Protected resource index
/resources/[slug]                   [M]  Individual protected resource
/courses                            [P]  Course catalog
/courses/[slug]                     [P]  Course marketing page
/courses/[slug]/content             [S]  Student course content (scoped)
/dashboard                          [S]  Student dashboard — enrolled courses list
/checkout                           [P]  Payment + account creation flow
/account                            [M]  Account settings
/login                              [P]  Login
/signup                             [P]  Signup (also triggered mid-checkout)
/reset-password                     [P]  Password reset

/admin                              [A]  Admin home
/admin/courses                      [A]  Manage courses + content
/admin/blog                         [A]  Manage blog posts
/admin/resources                    [A]  Manage protected resources
/admin/users                        [A]  View students, manage access
```

---

## 6. Feature Requirements

### 6.1 Landing Page (`/`)

- **Single primary CTA:** mailing list email signup. This is the hero action — large, obvious, impossible to miss.
- Course offerings visible but secondary to the mailing list CTA. Course is not absent; it is not the hero.
- About / intro section (can be a landing page section rather than a separate `/about` page — TBD in design).
- No heavy media at MVP. Any media references should resolve lazily (linked thumbnail → player, not autoplay embed). Landing page must stay lightweight for SEO.
- Contact (TBD: section on landing page or separate page).
- Standard footer: links, social, legal.

### 6.2 Blog / Free Content (`/blog`)

- SEO and GEO-optimized articles answering common meditation questions.
- Fully public and crawlable. All standard SEO metadata: title, description, OpenGraph, JSON-LD Article schema, canonical URLs.
- Searchable / filterable index page.
- Individual article pages (`/blog/[slug]`) statically generated at build time.
- Evan creates and publishes posts via admin CMS (Phase 3). At MVP, content is hardcoded or file-based.

### 6.3 Protected Resources (`/resources`)

- Mailing list members only (Tier 1+). Requires authentication.
- Free content — audio, PDFs, guided meditations, etc. — used as a lead magnet and funnel incentive.
- Index page shows available resources to authenticated users.
- Individual resource pages (`/resources/[slug]`) gated behind login check.
- Evan manages via admin CMS (Phase 3). MVP: hardcoded.

### 6.4 Course Marketing Pages (`/courses`, `/courses/[slug]`)

- Fully public and crawlable.
- Per-course page: description, Evan's background for this course, schedule/date, price, enroll CTA → checkout.
- Course catalog page lists all active courses.
- Statically generated for SEO. Content managed by Evan via admin CMS (Phase 3). MVP: hardcoded.

### 6.5 Course Content (`/courses/[slug]/content`)

Paid students only, scoped to their enrolled course(s).

**Content structure per course:**

| Section | Timing | Notes |
|---|---|---|
| Intro document | From enrollment | Overview, what to expect |
| Setting the stage | From enrollment | Pre-reading, framing materials |
| Zoom link (live session) | Shown at course time | Evan provides link, surfaces in dashboard |
| Recording link | After live session | Evan adds post-session; links to Zoom cloud recording |
| Meditation links / resources | Ongoing | Supplementary materials |

For MVP, Evan updates content by editing a record in the admin (or directly in the database / CMS). This does not need to be a rich media experience — links are sufficient.

### 6.6 Student Dashboard (`/dashboard`)

- Authenticated, paid students only.
- Lists all courses the student is enrolled in (left nav or card grid).
- Clicking a course opens that course's content view.
- Shows course status: upcoming / live / completed.
- MVP: simple, functional. No progress tracking, no completion markers yet.

### 6.7 Checkout & Enrollment (`/checkout`)

- Triggered from course marketing page CTA.
- Payment: PayPal at MVP, Stripe as target.
- On successful payment:
  - Account created (or existing account linked)
  - Course access row provisioned in DB
  - Student added to MailChimp "paid students" segment
  - Confirmation email sent (via MailChimp or transactional email)
- No subscription billing. Single-transaction purchases only.

### 6.8 Auth Pages

- Login, signup, password reset.
- Signup is triggered both from the mailing list CTA (Tier 1 account) and from checkout (Tier 2 account).
- Standard flows: email + password. Magic link or OAuth (Google) are nice-to-have, not MVP.

### 6.9 Admin CMS (`/admin`)

Built in Phase 3. Until then, content is hardcoded or managed directly.

**Admin/courses:** create/edit course records, attach content sections, set Zoom link + recording URL, publish/unpublish.
**Admin/blog:** create/edit/publish blog posts, set metadata.
**Admin/resources:** create/edit protected content items, attach files or links.
**Admin/users:** view all users, see enrollment status and mailing list tier, manually assign or revoke course access (for edge cases like refunds or comps).

---

## 7. Content Architecture

### Public content (no auth)
- Landing page copy + images
- Blog articles
- Course marketing copy

### Protected content (mailing list tier)
- Audio recordings, PDFs, guided meditations offered as list incentives
- Not available via direct URL — requires authenticated session

### Paid course content (student tier, per-course)
- Intro doc, setting the stage, Zoom link, recording link, meditation resources
- Scoped: student only sees courses they paid for

### Admin-managed
- All of the above, editable via CMS (Phase 3)
- User roster and access assignments

### MailChimp segments
- `subscribers` — mailing list, not enrolled
- `students-[course-slug]` — paid, enrolled in a specific course
- `students-all` — anyone who has ever purchased

---

## 8. Tech Stack

| Layer | Choice | Status | Notes |
|---|---|---|---|
| Frontend framework | Next.js (App Router) | Settled | SSG for public pages (SEO), SSR for auth routes. No Gatsby needed. |
| Hosting | Vercel | Settled | Native Next.js integration, edge CDN, CI/CD, good free tier to start. |
| Database | PostgreSQL (Neon or Railway) | Settled | Relational model for RBAC, students, courses, enrollments. Both have generous free tiers. Audit pricing cliffs before launch. |
| Authentication | TBD | **Open — blocker** | See §11. Decision required before build starts. |
| Payments (MVP) | PayPal | Settled | Bridges current manual flow. Webhook fires on payment to provision access. |
| Payments (target) | Stripe | Phased | Stripe's webhook model (`payment_intent.succeeded`) is cleaner for auto-provisioning. Migrate when PayPal becomes a bottleneck. |
| Email / CRM | MailChimp (existing) | Settled | Keep existing account. Segment by tier. Abandon cart, drip, upsell sequences. |
| Analytics | TBD | Open | Plausible ($9/mo, privacy-first, lightweight) is the default recommendation. PostHog if full product analytics are needed. GA4 if budget is the constraint. |
| SEO / GEO | Next.js metadata API + llms.txt | Settled | Static sitemap, robots.txt, OpenGraph, JSON-LD. `llms.txt` for AI crawler guidance. |
| CMS (content) | Custom admin UI | Phased | Hardcoded/file-based at MVP. Admin CRUD in Phase 3. |
| Community | Circle.so or custom | Future | Not in MVP. |

### Database schema (sketch)

```
users           id, email, password_hash, role, mailchimp_id, created_at
courses         id, slug, title, description, zoom_link, recording_url, status, published_at
course_content  id, course_id, section (enum), content_type, content_url, sort_order
enrollments     id, user_id, course_id, paid_at, payment_ref, access_granted
posts           id, slug, title, body, published_at, seo_meta
resources       id, slug, title, content_type, content_url, published_at
```

---

## 9. Integrations

| Service | Purpose | Trigger |
|---|---|---|
| MailChimp | Mailing list, drip sequences, student segments | Signup form → subscribe. Payment success → add to student segment. |
| PayPal (MVP) | Payment processing | Checkout → IPN webhook → provision enrollment row |
| Stripe (target) | Payment processing | `payment_intent.succeeded` → provision enrollment row |
| Zoom | Live session delivery + recording | Evan manages externally; URL stored in DB and surfaced to students |
| Plausible / GA4 | Analytics | Page load (script tag) |

---

## 10. Build Phases

Ordered by leverage: top + bottom of funnel first (direct revenue impact), then content / middle funnel, then ops / admin, then polish.

### Phase 1 — Top & Bottom of Funnel

*Outcome: a stranger can find the site, sign up to the mailing list, enroll in a course, pay, and access their content.*

- Landing page with mailing list CTA
- MailChimp signup form integration
- Course marketing pages (static, SEO-optimized)
- Checkout + PayPal payment
- Account creation on purchase + confirmation email
- Basic student dashboard (hardcoded course content)
- Auth: login / signup / password reset
- Course content pages (hardcoded structure)

### Phase 2 — Content & Middle Funnel

*Outcome: inbound content machine is running; mailing list members have a reason to stay.*

- Blog / free articles (SEO/GEO-optimized, JSON-LD schema)
- Protected resources section + mailing list auth gating
- `llms.txt`, `sitemap.xml`, `robots.txt`, structured data
- Analytics integration (Plausible or GA4)
- OpenGraph / social sharing metadata

### Phase 3 — Admin & Operations

*Outcome: Evan can manage content without a developer.*

- Admin CMS for course content (sections, Zoom links, recording URLs)
- Admin CMS for blog posts
- Admin CMS for protected resources
- User management (view roster, assign/revoke access)
- MailChimp webhook wiring (auto-add to segment on enrollment)

### Phase 4 — Polish & Community

*Outcome: richer student experience; community begins.*

- Hosted video / embedded player (replace raw Zoom recording links)
- Student community / forums (Circle.so integration or custom)
- Bookmarking, notes, completion tracking within course content
- Student profiles
- Stripe migration (if still on PayPal)
- Course gifting / comps / discount codes

---

## 11. Open Questions

| # | Question | Owner | Priority |
|---|---|---|---|
| 1 | **Auth library choice** — BetterAuth, Supabase Auth, or Firebase Auth? This decision gates the entire build. BetterAuth = full control, more implementation work. Supabase = batteries included, ties you to their infra. Firebase = hosted, easy, separate ecosystem from Vercel/Postgres. | Thomas | **Blocker** |
| 2 | **Mailing list auth tier** — Is protected-content-for-subscribers worth the account-creation friction? Could simplify to just two user states: anonymous and paid student. Mailing list incentives could be public content that isn't promoted, rather than auth-gated content. | Evan + Thomas | Phase 1 |
| 3 | **Analytics choice** — Plausible (paid, lightweight, privacy-first), PostHog (generous free tier, product analytics), or GA4 (free, heavy)? | Thomas | Phase 1 |
| 4 | **About / Contact** — Separate pages or sections on the landing page? | Evan | Design phase |
| 5 | **Pricing cliff audit** — Check Neon and Railway free tier limits and the cost at the next tier before launching. | Thomas | Pre-launch |
| 6 | **PayPal → Stripe migration timing** — When does PayPal become painful enough to warrant switching? Define the trigger (e.g., first 20 students, first manual access-provisioning failure). | Thomas | Phase 1 review |
| 7 | **Recording hosting long-term** — Zoom cloud recordings expire or have storage limits. When do we migrate to hosted video (Mux, Cloudflare Stream, Vimeo)? | Thomas | Phase 4 |

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

1. **Resolve auth decision** (§11, Q1) — no code until this is settled.
2. **Design phase** — wireframes per page type using thefield.us as aesthetic reference. Landing page first.
3. **Agree on mailing list auth tier** (§11, Q2) — simplest possible RBAC is usually right for MVP.
4. **Phase 1 build** — landing page + checkout + basic student dashboard.
