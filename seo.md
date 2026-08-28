# EvanLeed.com Rebuild — Complete Developer / Designer / SEO Handoff

**Target platform:** Next.js App Router + Vercel
**Document status:** Build specification / controlled implementation handoff
**Recommended change class:** **Class C — Material Revision**
**Primary domain:** `https://www.evanleed.com`
**Prepared:** August 28, 2026

This document is intended to be sufficient for a competent developer to rebuild EvanLeed.com from scratch without having to infer the SEO/GEO/AEO architecture, migration behavior, content responsibilities, analytics model, or launch controls.

It also treats the rebuild as a controlled operational change rather than a visual redesign. That follows the uploaded SOP's requirements that a material change define its outcome, evidence, metrics, dependencies, pilot/rollout, rollback, decision thresholds, versioning, and effectiveness review.

---

# 1. Executive brief

## What we are building

A fast, editorially restrained, technically clean website that positions **Evan Leed as a specialist in the Ideal Parent Figure Protocol (IPF)** and creates two complementary layers:

**Commercial layer**

`Evan → fit → credibility → how the work works → consultation`

**Authority / retrieval layer**

`IPF → concepts → practice → evidence → limitations → Evan's experience → services`

The site must feel closer to **The Field** and **Daniel Thorson** than to a high-volume wellness-content farm, while having the retrieval depth and internal topic architecture that makes **Attachment Repair** effective in organic and generative search.

The Field demonstrates the value of restrained navigation, strong editorial identity, practitioner authority, sophisticated audience positioning, and substantive content without a cluttered interface. ([The Field][1]) Daniel Thorson's site is particularly strong at describing exactly who the work is for, including intellectually sophisticated and established practitioners, while keeping the primary navigation extremely narrow. ([Daniel Thorson][2]) Attachment Repair provides the opposite lesson: its major advantage is a large, segmented corpus spanning articles, meditations, assessments, courses, attachment styles and problem areas. ([Attachment Repair][3])

## What we are not building

Do **not** build:

- a generic therapist template;
- a sprawling wellness mega-menu;
- a 100-page AI-generated content farm;
- a JavaScript-heavy animation showcase;
- duplicate pages for every keyword variation;
- separate "SEO" and "AI" versions of content;
- a site dependent on FAQ schema, `llms.txt`, hidden keyword blocks, or proprietary "GEO markup";
- a homepage that attempts to contain Evan's biography, entire methodology, all FAQs, all events, all pricing and all research.

Google's August 2026 generative-search guidance explicitly says core SEO remains the foundation for AI search; it recommends valuable non-commodity content and says special AI markup, special AI text files, artificial chunking, and AI-specific rewrites are unnecessary for Google Search. ([Google Developers][4])

---

# 2. Product outcome

## Primary intended outcome

> Build the most technically reliable, authoritative, easily understood first-party web source for Evan Leed and his work with the Ideal Parent Figure Protocol, converting qualified visitors into consultation requests while creating a growing corpus that search engines and grounded AI systems can discover, retrieve and cite.

## Primary audience

The site should preferentially attract people who are:

- psychologically literate;
- already familiar with therapy, meditation or personal development;
- capable and functional in many areas of life;
- aware of recurring relational or attachment patterns;
- dissatisfied with insight that has not translated into lived change;
- interested in experiential rather than purely conceptual work;
- comfortable with thoughtful, non-hyped communication;
- seeking an IPF specialist rather than a generalist.

That audience strategy is strongly informed by Thorson's explicit positioning around people who already understand a great deal intellectually but experience a gap between understanding and embodiment. ([Daniel Thorson][2])

---

# 3. Non-negotiable build principles

The developer should treat these as acceptance criteria, not suggestions.

| Principle          | Requirement                                              |
| ------------------ | -------------------------------------------------------- |
| Rendering          | Core content must exist in server-rendered HTML          |
| Framework          | Next.js App Router                                       |
| Hosting            | Vercel                                                   |
| Language           | TypeScript                                               |
| Canonical host     | `https://www.evanleed.com`                               |
| URL style          | Lowercase, hyphenated, no trailing slash                 |
| Rendering strategy | Static/ISR wherever practical                            |
| Client JS          | Minimize; Server Components by default                   |
| Content editing    | Structured CMS strongly preferred                        |
| Metadata           | Native Next.js Metadata API                              |
| Canonicals         | Explicit self-canonical on every indexable page          |
| Sitemap            | Generated dynamically from canonical content             |
| Robots             | Generated from code/config; deliberate AI-crawler policy |
| Schema             | JSON-LD generated from typed data                        |
| Accessibility      | WCAG 2.2 AA target                                       |
| Analytics          | Search + AI + conversion instrumentation                 |
| Preview            | Noindex + deployment protection                          |
| Events             | Date/state-driven; no hardcoded expired "open" messages  |
| Claims             | Controlled source/evidence registry                      |
| Pricing            | One central source of truth                              |
| Scope disclaimer   | One central source of truth                              |
| Redirects          | Every legacy URL accounted for before launch             |
| Rollback           | Previous production build immediately restorable         |

The SOP specifically recommends separating the controlled source of truth from its presentation and avoiding frequently changing values duplicated in multiple locations. Evan's current site shows exactly why: `/` and `/about` currently contain effectively the same content, while event information has diverged between pages. ([Evan Leed][5])

---

# 4. Recommended technical stack

## Core

```text
Next.js — current stable App Router
React — version required by current Next.js
TypeScript
pnpm
Vercel
Tailwind CSS or equivalent lightweight styling system
Zod for data validation
```

Do not pin this document to a particular Next.js patch number. At implementation start, install the current stable release, lock it in `pnpm-lock.yaml`, and record that version in the deployment handoff.

Next.js provides native metadata, canonical, robots and sitemap capabilities through its Metadata API and file conventions. ([Next.js][6])

## CMS recommendation

### Preferred: Sanity

Use a structured headless CMS because Evan needs to be able to update:

- articles;
- publication dates;
- events;
- course status;
- prices;
- testimonials;
- research citations;
- metadata;
- page content;

without a developer deployment for every copy change.

Sanity is a recommendation, not an SEO requirement. Equivalent structured systems are acceptable if the implementation preserves the content model in this document.

### Acceptable alternative

MDX stored in Git is acceptable **only if Evan is comfortable editing through a Git-backed workflow**.

Do not use an unstructured WYSIWYG CMS that turns every page into arbitrary free-form HTML.

---

# 5. Repository structure

Recommended:

```text
/
├── src/
│   ├── app/
│   │   ├── layout.tsx
│   │   ├── page.tsx
│   │   ├── not-found.tsx
│   │   ├── robots.ts
│   │   ├── sitemap.ts
│   │   ├── manifest.ts
│   │   ├── opengraph-image.tsx
│   │   │
│   │   ├── about/
│   │   │   └── page.tsx
│   │   ├── the-work/
│   │   │   └── page.tsx
│   │   ├── who-this-is-for/
│   │   │   └── page.tsx
│   │   ├── ideal-parent-figure-protocol/
│   │   │   └── page.tsx
│   │   ├── contact/
│   │   │   └── page.tsx
│   │   ├── guides/
│   │   │   ├── page.tsx
│   │   │   └── [slug]/
│   │   │       └── page.tsx
│   │   ├── events/
│   │   │   ├── page.tsx
│   │   │   └── [slug]/
│   │   │       └── page.tsx
│   │   ├── courses/
│   │   │   └── [slug]/
│   │   │       └── page.tsx
│   │   ├── privacy/
│   │   │   └── page.tsx
│   │   ├── scope-and-safety/
│   │   │   └── page.tsx
│   │   └── api/
│   │       ├── contact/
│   │       │   └── route.ts
│   │       └── indexnow/
│   │           └── route.ts
│   │
│   ├── components/
│   │   ├── layout/
│   │   ├── content/
│   │   ├── conversion/
│   │   ├── seo/
│   │   ├── events/
│   │   └── ui/
│   │
│   ├── lib/
│   │   ├── cms/
│   │   ├── seo/
│   │   ├── analytics/
│   │   ├── schema/
│   │   ├── claims/
│   │   ├── urls/
│   │   └── validation/
│   │
│   ├── config/
│   │   ├── site.ts
│   │   ├── navigation.ts
│   │   ├── business.ts
│   │   ├── crawlers.ts
│   │   └── redirects.ts
│   │
│   └── styles/
│       └── globals.css
│
├── public/
│   ├── images/
│   ├── audio/
│   ├── favicon.ico
│   └── indexnow-key.txt
│
├── tests/
│   ├── seo/
│   ├── accessibility/
│   ├── routes/
│   └── e2e/
│
├── next.config.ts
├── eslint.config.mjs
├── package.json
└── pnpm-lock.yaml
```

---

# 6. Final information architecture

Primary navigation:

```text
IPF
Work With Me
Who It's For
About
Guides
Events
[Book a Call]
```

Do not put Contact in the main desktop nav if the consultation CTA already provides that function.

Footer:

```text
IPF
Work With Me
Who It's For
About
Guides
Events
Contact
Scope & Safety
Privacy
Newsletter
```

The goal is to retain The Field/Thorson-level navigational restraint while building Attachment Repair-level topical depth _beneath_ the primary navigation rather than inside it. The Mettagroup homepage currently exposes a large number of programs, services and sub-offers simultaneously; that demonstrates the discoverability benefits of an ecosystem but also the navigational complexity Evan specifically wants to avoid. ([Mettagroup][7])

---

# 7. Canonical route inventory

## Core routes

| URL                             | Purpose                                 | Index |
| ------------------------------- | --------------------------------------- | ----: |
| `/`                             | Brand/entity/commercial homepage        |   Yes |
| `/about`                        | Evan biography, training and provenance |   Yes |
| `/the-work`                     | 1:1 IPF service                         |   Yes |
| `/who-this-is-for`              | Audience qualification                  |   Yes |
| `/ideal-parent-figure-protocol` | Flagship IPF authority resource         |   Yes |
| `/guides`                       | Knowledge hub                           |   Yes |
| `/events`                       | Current programs/events                 |   Yes |
| `/contact`                      | Consultation/contact                    |   Yes |
| `/scope-and-safety`             | Scope, limitations, crisis boundaries   |   Yes |
| `/privacy`                      | Privacy information                     |   Yes |

## Commercial/program routes

```text
/events/ipf-weekend-retreat
/courses/i-can-relate
```

If the existing `/ipf-weekend-retreat` has meaningful links/indexing, keeping the legacy path is acceptable and probably safer than moving it. In that case:

```text
/ipf-weekend-retreat
```

remains canonical permanently.

---

# 8. Preserve these legacy URLs

The following existing URLs are publicly observable today and must not disappear at migration:

```text
/
/about
/the-work
/contact
/ipf-weekend-retreat
```

The current site is already indexed under these paths. ([Evan Leed][5])

Before launch, perform a complete legacy inventory from:

1. Squarespace page export.
2. XML sitemap.
3. Google Search Console Pages report.
4. GSC top landing pages.
5. Bing Webmaster indexed URLs.
6. Analytics landing-page history.
7. External backlink export if available.
8. Site crawl.

**Launch cannot proceed until every discovered legacy URL is assigned one of:**

```text
200 preserve
308 permanent redirect
404 intentionally absent
410 intentionally removed
```

There must be **zero unidentified legacy URLs in the migration sheet**.

---

# 9. Redirect policy

Use permanent redirects only when the old URL has a genuine replacement.

Example:

```ts
// next.config.ts
import type { NextConfig } from 'next';

const nextConfig: NextConfig = {
  async redirects() {
    return [
      {
        source: '/relationship-course-summer-2026',
        destination: '/courses/i-can-relate',
        permanent: true,
      },
    ];
  },
};

export default nextConfig;
```

Next.js permanent redirects use HTTP 308 by default, which is appropriate here. ([Next.js][8])

Do **not** redirect:

```text
/about → /
/the-work → /ideal-parent-figure-protocol
```

They are intended to become separate, useful pages.

Do not create redirect chains.

Bad:

```text
/old → /older → /new
```

Required:

```text
/old → /new
/older → /new
```

---

# 10. Host normalization

Production canonical:

```text
https://www.evanleed.com
```

Vercel domain configuration:

```text
www.evanleed.com     PRIMARY
evanleed.com         REDIRECT → www.evanleed.com
```

Also normalize:

```text
http → https
trailing slash → no trailing slash
```

Do not implement host normalization in middleware if Vercel Domains can handle it directly.

Google treats canonicalization as clustering of duplicate URLs and uses redirects, canonical annotations, sitemaps and other signals; the signals should agree. ([Google Developers][9])

---

# 11. Central source-of-truth configuration

One of the most important engineering changes is to stop duplicating changing facts in copy.

Create a global business-settings object in the CMS.

Example:

```ts
export interface BusinessSettings {
  sessionDurationMinutes: number;
  consultationDurationMinutes: number;
  standardSessionPriceUsd: number;
  slidingScaleMinimumUsd: number | null;

  calendlyUrl: string;
  contactEmail: string;

  scopeStatement: string;

  acceptsNewClients: boolean;

  training: TrainingRecord[];
  socialProfiles: SocialProfile[];
}
```

Current values to verify with Evan before launch:

```text
Session duration: 50 minutes
Session price: $200
Sliding-scale floor: $150
Consultation: 30 minutes
Delivery: online
```

These values are currently repeated on the site. ([Evan Leed][5])

Every page should render them from one source.

Never manually write `$200` into four separate pages.

---

# 12. Claims registry

Because the subject touches attachment, trauma and psychological outcomes, implement a structured editorial claims register.

Suggested type:

```ts
export interface Claim {
  id: string;

  shortName: string;

  approvedWording: string;
  prohibitedWording?: string[];

  claimType:
    | 'biographical'
    | 'training'
    | 'research'
    | 'service'
    | 'practice-observation'
    | 'testimonial';

  sourceUrl?: string;
  sourceCitation?: string;

  verifiedBy: string;
  verifiedAt: string;
  reviewAfter?: string;

  allowedPages?: string[];
}
```

Examples:

```text
CLAIM-TRAIN-001
"Studied in Dr. Daniel P. Brown's IPF Masterclass for nearly two years"

CLAIM-SCOPE-001
"Evan provides IPF facilitation/coaching, not psychotherapy."

CLAIM-PRICE-001
"Sessions are $200 for 50 minutes."

CLAIM-RESEARCH-001
[Precise wording only after primary-source review.]
```

This prevents unsupported claims from propagating across the site.

The current site contains stronger language such as "research-based," "rewiring your nervous system," "clinically researched," and guaranteed-sounding descriptions of lasting change. ([Evan Leed][5]) Those should be reviewed before migration rather than copied wholesale.

---

# 13. Page specification — Homepage

## URL

```text
/
```

## SEO title

```text
Evan Leed — Ideal Parent Figure (IPF) Facilitator
```

## Meta description

```text
Online Ideal Parent Figure facilitation with Evan Leed. Learn about IPF, one-to-one sessions, attachment-focused work, classes and retreats.
```

## H1

```text
Ideal Parent Figure Facilitation with Evan Leed
```

## Page order

```text
Hero
↓
Audience recognition
↓
What IPF is
↓
What changes people come to work on
↓
Why Evan
↓
Training / lineage
↓
Client voices
↓
How working together begins
↓
Scope statement
↓
Consultation CTA
```

## Hero recommendation

Eyebrow:

```text
Ideal Parent Figure Protocol · Online facilitation
```

H1:

```text
Ideal Parent Figure Facilitation with Evan Leed
```

Supporting copy:

> Attachment patterns can make perfect sense intellectually and still continue to shape how closeness, trust and self-worth feel in practice. I work with people who want an experiential way to approach that gap using the Ideal Parent Figure Protocol.

CTA 1:

```text
Book a free consultation
```

CTA 2:

```text
What is IPF?
```

Avoid phrases like:

```text
heal your trauma
rewire your nervous system
change deeper than therapy
guaranteed earned security
```

unless a qualified reviewer approves the exact claim.

---

# 14. Homepage — audience section

Take inspiration from Thorson's highly explicit audience qualification without copying its wording. ([Daniel Thorson][2])

## H2

```text
You may recognize yourself here
```

Use four cards.

### Card 1

**You understand the pattern, but understanding hasn't changed it**

You've read, reflected, perhaps spent years in therapy or personal work. You can explain the pattern. It still activates.

### Card 2

**Your contemplative practice hasn't resolved everything relational**

Meditation may have changed your life while certain patterns around intimacy, trust or self-worth remain surprisingly persistent.

### Card 3

**Your outer life works better than your inner sense of security**

You may be capable, successful and self-aware while relationships still produce disproportionate uncertainty, withdrawal or self-criticism.

### Card 4

**You want an approach that respects your intelligence**

You want to understand the method, its limitations and the evidence rather than surrender judgment to a practitioner.

CTA:

```text
See who this work is for →
```

---

# 15. Page specification — `/who-this-is-for`

## Title

```text
Who IPF Work Is For | Evan Leed
```

## H1

```text
Who This Work Is For
```

## H2s

```text
When insight hasn't become felt change
When contemplative practice leaves relational patterns untouched
When life works but closeness remains difficult
When you want depth without therapeutic marketing
When IPF may not be the right support
How to decide whether to speak with me
```

Purpose:

**Commercial qualification**, not mass traffic.

This is one of the most important lessons from the Thorson reference: the target reader should know within a few minutes whether Evan is speaking specifically to them. ([Daniel Thorson][2])

---

# 16. Page specification — `/about`

## Title

```text
About Evan Leed | IPF Training & Background
```

## Meta

```text
Learn about Evan Leed's background, Ideal Parent Figure training with Dr. Daniel P. Brown, ongoing mentorship with George Haas and contemplative practice.
```

## H1

```text
About Evan Leed
```

## H2s

```text
How I came to this work
My training in the Ideal Parent Figure Protocol
My work with George Haas and Mettagroup
My contemplative background
How I approach facilitation
Experience with clients and groups
Scope of practice
```

## Design requirement

Create a visually distinct **Training & provenance** module.

Example:

```text
IDEAL PARENT FIGURE PROTOCOL
Studied in Dr. Daniel P. Brown's IPF Masterclass for nearly two years.

METTAGROUP
Ongoing mentorship with George Haas.

CONTEMPLATIVE PRACTICE
Long-standing personal meditation practice.
```

Every biographical statement must be verified before publishing.

---

# 17. Page specification — `/the-work`

## Title

```text
Online Ideal Parent Figure Sessions | Evan Leed
```

## Meta

```text
Learn how one-to-one Ideal Parent Figure sessions with Evan Leed work, including session format, frequency, pricing, scope and consultation options.
```

## H1

```text
Online Ideal Parent Figure Sessions
```

## H2s

```text
What we work with
What happens during a session
What the facilitator does
How often we meet
What IPF facilitation is — and isn't
Pricing and sliding scale
Frequently asked questions
Start with a free consultation
```

## Must remove from this page

- current event dates;
- temporary promotional banners;
- old workshops;
- course schedules;
- long biography.

The current `/the-work` still mixes evergreen service information with event dates and future course promotion. ([Evan Leed][10])

---

# 18. Flagship authority page

## URL

```text
/ideal-parent-figure-protocol
```

## Title

```text
Ideal Parent Figure Protocol (IPF): Complete Guide | Evan Leed
```

## H1

```text
What Is the Ideal Parent Figure Protocol?
```

## Direct-answer block

The first 75–120 words should answer the question directly.

Recommended form:

> The Ideal Parent Figure Protocol, or IPF, is a structured guided-imagery practice used in attachment-focused work. A participant imagines ideal caregivers providing qualities such as protection, attunement, soothing, delight and support for exploration. A facilitator helps adapt the imagery to the person's experience. On this site, IPF refers to facilitation and education rather than psychotherapy or medical treatment.

Final wording should undergo subject-matter and research review.

## H2 structure

```text
IPF in one minute

Where the Ideal Parent Figure Protocol came from

The five conditions used in IPF
    Safety
    Attunement
    Soothing and emotional regulation
    Delight
    Support for exploration and growth

What happens during an IPF session?

Do you need to visualize clearly?

Do you need to revisit traumatic memories?

What is earned secure attachment?

Is IPF psychotherapy?

What does the research actually support?

Who may want to explore IPF?

When another kind of support may be more appropriate

Frequently asked questions

Sources and further reading

Work with Evan
```

This page is the primary hub for both classic SEO and GEO/AEO.

---

# 19. Guides hub

## URL

```text
/guides
```

## Title

```text
IPF & Attachment Guides | Evan Leed
```

## H1

```text
Guides to IPF, Attachment and Secure Relating
```

Categories:

```text
Start Here
Understanding IPF
Practice & Sessions
Attachment Concepts
Evidence & Scope
Choosing Support
```

Every guide card displays:

```text
Title
One-sentence summary
Topic
Published date
Updated date if material
Reading time — optional, not required
```

---

# 20. First 10 GEO/AEO guides

Publish in this order.

|   # | URL                                            | H1                                                        |
| --: | ---------------------------------------------- | --------------------------------------------------------- |
|   1 | `/ideal-parent-figure-protocol`                | What Is the Ideal Parent Figure Protocol?                 |
|   2 | `/guides/five-conditions-of-secure-attachment` | The Five Conditions of Secure Attachment in IPF           |
|   3 | `/guides/what-happens-in-an-ipf-session`       | What Happens During an Ideal Parent Figure Session?       |
|   4 | `/guides/is-ipf-therapy`                       | Is the Ideal Parent Figure Protocol Therapy?              |
|   5 | `/guides/earned-secure-attachment`             | What Does Earned Secure Attachment Mean?                  |
|   6 | `/guides/ipf-trouble-visualizing`              | Can You Do IPF If You Have Trouble Visualizing?           |
|   7 | `/guides/ipf-research-evidence`                | What Research Exists on the Ideal Parent Figure Protocol? |
|   8 | `/guides/choosing-an-ipf-facilitator`          | How to Choose an Ideal Parent Figure Facilitator          |
|   9 | `/guides/when-ipf-may-not-be-right`            | When Might IPF Not Be the Right Support?                  |
|  10 | `/guides/how-often-ipf-sessions`               | How Often Should You Meet for IPF Sessions?               |

Do not publish all ten on launch day.

Recommended cadence:

```text
Launch:
#1

Week 2:
#2

Week 3:
#3

Week 4:
#4

Week 5:
#5

Week 6:
#6

Week 7–8:
#7 after evidence review

Week 9:
#8

Week 10:
#9

Week 11:
#10
```

The SOP explicitly recommends controlled improvement experiments and evidence-based ramp rather than broad uncontrolled change.

---

# 21. Article template

Every guide should share one controlled template.

```text
Breadcrumbs

Article eyebrow / category

H1

Direct answer
40–120 words

Key points
3–5 concise items

Main body
H2/H3

Practitioner perspective
Clearly marked as Evan's observation

Evidence / research
Where relevant

Limits / qualifications
Where relevant

Sources

Related guides

About Evan

CTA
```

Important distinction:

### Scientific or historical claim

Use source/citation.

### Evan's practitioner observation

Label as first-person experience.

Example:

```text
In my experience facilitating IPF...
```

Do not blur these two categories.

---

# 22. Content components

Build reusable components rather than arbitrary rich-text styling.

Minimum set:

```text
<Hero />
<Section />
<Container />
<Prose />
<DirectAnswer />
<KeyTakeaways />
<EvidenceNote />
<PractitionerNote />
<ScopeNotice />
<TrainingLineage />
<Testimonial />
<TestimonialGrid />
<PriceBlock />
<ConsultationCTA />
<NewsletterCTA />
<Breadcrumbs />
<ArticleMeta />
<SourceList />
<RelatedGuides />
<FAQAccordion />
<EventCard />
<CourseCard />
<AudioPractice />
<AuthorCard />
<Callout />
```

This makes visual and semantic consistency enforceable.

---

# 23. Testimonials

Store testimonials structurally.

```ts
interface Testimonial {
  quote: string;
  displayName: string;
  role?: string;

  context: 'one-to-one' | 'class' | 'retreat';

  consentConfirmed: boolean;
  approvedForPublicUse: boolean;
}
```

Do not embed raw testimonial copy in page components.

Do not rotate testimonials randomly server-side because it can make search/cached versions inconsistent.

---

# 24. Event data model

This is important because stale events are already a site failure.

```ts
interface Event {
  title: string;
  slug: string;

  startDate: string;
  endDate: string;
  timezone: string;

  format: 'online' | 'in-person' | 'hybrid';

  registrationOpenAt?: string;
  registrationCloseAt?: string;

  capacity?: number;

  status: 'draft' | 'announced' | 'registration-open' | 'sold-out' | 'completed' | 'cancelled';

  priceTiers: PriceTier[];

  registrationUrl?: string;

  description: PortableText;
}
```

## UI rules

If:

```text
status = registration-open
```

show:

```text
Register
```

If current time > `endDate`:

show:

```text
This event has concluded.
Join the list for the next one.
```

Do not rely on Evan remembering to manually edit every page after an event.

---

# 25. Event structured-data state

Only output Event JSON-LD when the page represents a specific scheduled event.

When the evergreen retreat page has no scheduled date, do **not** output a dated Event object.

If the event is cancelled, update structured data accordingly.

Event schema data must be generated from the same source as visible dates.

**Never have visible date A and schema date B.**

---

# 26. Metadata architecture

Root:

```ts
// src/app/layout.tsx
import type { Metadata } from 'next';

const siteUrl = 'https://www.evanleed.com';

export const metadata: Metadata = {
  metadataBase: new URL(siteUrl),

  title: {
    default: 'Evan Leed — Ideal Parent Figure (IPF) Facilitator',
    template: '%s | Evan Leed',
  },

  description:
    'Ideal Parent Figure facilitation, attachment-focused education, guides, classes and retreats with Evan Leed.',

  alternates: {
    canonical: '/',
  },

  openGraph: {
    siteName: 'Evan Leed',
    type: 'website',
    locale: 'en_US',
  },

  twitter: {
    card: 'summary_large_image',
  },
};
```

Next.js supports static metadata or `generateMetadata()` and automatically creates the corresponding head elements. ([Next.js][6])

---

# 27. Page metadata helper

Create one helper so developers do not reinvent SEO page-by-page.

```ts
interface PageSEO {
  title: string;
  description: string;
  path: string;

  image?: string;
  noindex?: boolean;
}

export function buildMetadata({
  title,
  description,
  path,
  image = '/images/og/default.jpg',
  noindex = false,
}: PageSEO): Metadata {
  const canonical = new URL(path, SITE_URL).toString();

  return {
    title,
    description,

    alternates: {
      canonical,
    },

    robots: {
      index: !noindex,
      follow: !noindex,
    },

    openGraph: {
      title,
      description,
      url: canonical,
      images: [image],
    },

    twitter: {
      card: 'summary_large_image',
      title,
      description,
      images: [image],
    },
  };
}
```

---

# 28. Preview deployment indexing

All Vercel Preview environments must be:

```text
noindex
nofollow
```

and preferably protected with Vercel Deployment Protection.

Do this from environment state, not manually.

Concept:

```ts
const isProduction = process.env.VERCEL_ENV === 'production';

export const metadata: Metadata = {
  robots: isProduction ? { index: true, follow: true } : { index: false, follow: false },
};
```

Test rendered HTML on an actual Preview URL.

---

# 29. Robots policy

Use `src/app/robots.ts`.

Recommended owner decision:

**Allow search discovery via OpenAI.**
**Decide separately whether GPTBot training access is desired.**

OpenAI explicitly distinguishes `OAI-SearchBot` for search discovery from `GPTBot` for potential training use and states that ChatGPT referrals include `utm_source=chatgpt.com`. ([OpenAI Help Center][11])

Example:

```ts
import type { MetadataRoute } from 'next';

export default function robots(): MetadataRoute.Robots {
  return {
    rules: [
      {
        userAgent: '*',
        allow: '/',
        disallow: ['/api/', '/preview/'],
      },
      {
        userAgent: 'OAI-SearchBot',
        allow: '/',
      },

      // OWNER DECISION REQUIRED:
      // {
      //   userAgent: 'GPTBot',
      //   disallow: '/',
      // },
    ],

    sitemap: 'https://www.evanleed.com/sitemap.xml',
    host: 'https://www.evanleed.com',
  };
}
```

Do not block:

```text
/_next/
/images/
CSS
JS required to render
```

---

# 30. `llms.txt`

Do not make `llms.txt` a launch requirement.

Google clarified in June 2026 that its Search systems ignore `llms.txt` for visibility/ranking; its AI optimization guidance says special AI text files are unnecessary. ([Google Developers][12])

If another identified platform later documents support for a specific machine-readable file, add it as an explicit platform integration—not as SEO folklore.

---

# 31. Sitemap

Use `app/sitemap.ts`.

```ts
import type { MetadataRoute } from 'next';

export default async function sitemap(): Promise<MetadataRoute.Sitemap> {
  const staticPages = [
    '',
    '/about',
    '/the-work',
    '/who-this-is-for',
    '/ideal-parent-figure-protocol',
    '/guides',
    '/events',
    '/contact',
    '/scope-and-safety',
    '/privacy',
  ];

  const guides = await getPublishedGuides();
  const events = await getPublishedEvents();
  const courses = await getPublishedCourses();

  return [
    ...staticPages.map((path) => ({
      url: `https://www.evanleed.com${path}`,
    })),

    ...guides.map((guide) => ({
      url: `https://www.evanleed.com/guides/${guide.slug}`,
      lastModified: guide.updatedAt,
    })),

    ...events.map((event) => ({
      url: `https://www.evanleed.com/events/${event.slug}`,
      lastModified: event.updatedAt,
    })),

    ...courses.map((course) => ({
      url: `https://www.evanleed.com/courses/${course.slug}`,
      lastModified: course.updatedAt,
    })),
  ];
}
```

`lastModified` must represent a **meaningful content update**, not every deployment.

Sitemaps remain a fundamental discovery mechanism, including in AI-powered search; Bing also recommends pairing them with IndexNow for freshness. ([Bing Blogs][13])

---

# 32. IndexNow

Implement IndexNow for:

```text
new article published
article materially updated
event published
event status changed
page removed
redirect introduced
```

CMS webhook:

```text
Publish
→ Vercel API route
→ validate webhook secret
→ obtain canonical URL
→ submit URL to IndexNow
```

Do not submit every deployment.

Bing specifically recommends IndexNow to surface added, changed or removed content more quickly across participating search systems and its AI surfaces. ([Bing Blogs][14])

---

# 33. Schema architecture

Schema must be generated from structured data, never hand-maintained separately from visible content.

## Sitewide

```text
Person
WebSite
```

## About

```text
ProfilePage
Person
BreadcrumbList
```

## The Work

```text
WebPage
Service
BreadcrumbList
```

## Article

```text
Article
Person
BreadcrumbList
```

## Guides hub

```text
CollectionPage
```

## Events index

```text
CollectionPage
```

## Individual scheduled event

```text
Event
```

## Contact

```text
ContactPage
```

Do **not** add a special "AI schema."

Google says structured data remains useful for normal Search features but there is no special Schema.org markup required for generative AI Search. ([Google Developers][15])

---

# 34. Sitewide Person entity

Concept:

```ts
export const evanPerson = {
  '@type': 'Person',
  '@id': 'https://www.evanleed.com/#evan-leed',

  name: 'Evan Leed',

  url: 'https://www.evanleed.com/about',

  jobTitle: 'Ideal Parent Figure Facilitator',

  knowsAbout: ['Ideal Parent Figure Protocol', 'Attachment', 'Meditation'],

  sameAs: [
    // VERIFIED PROFILE URLs ONLY
  ],
};
```

Do not insert:

- unverified credentials;
- fake author profiles;
- unrelated directory listings;
- aspirational relationships.

---

# 35. Article JSON-LD

```tsx
const articleSchema = {
  '@context': 'https://schema.org',
  '@type': 'Article',

  '@id': `${canonical}#article`,
  mainEntityOfPage: canonical,

  headline: article.title,

  datePublished: article.publishedAt,
  dateModified: article.updatedAt,

  author: {
    '@id': 'https://www.evanleed.com/#evan-leed',
  },

  image: article.image?.url,
};
```

Render:

```tsx
<script
  type="application/ld+json"
  dangerouslySetInnerHTML={{
    __html: JSON.stringify(articleSchema),
  }}
/>
```

Sanitize/serialize trusted structured data only.

---

# 36. FAQ implementation

Keep FAQ sections because users and answer engines benefit from direct questions.

Do **not** build the project around FAQ rich results.

Google deprecated FAQ rich results in May 2026. ([Google Developers][12])

Use semantic HTML:

```html
<section aria-labelledby="faq-heading">
  <h2 id="faq-heading">Frequently asked questions</h2>

  <article>
    <h3>Is IPF therapy?</h3>
    <p>...</p>
  </article>
</section>
```

Accordion behavior is optional.

If using an accordion, the answer should remain in the DOM and accessible.

---

# 37. Internal linking requirements

Every new guide must link to:

```text
1 parent hub
2 related guides
1 Evan/About entity page
1 commercial page
```

Example:

```text
five-conditions guide
→ /ideal-parent-figure-protocol
→ /guides/earned-secure-attachment
→ /guides/what-happens-in-an-ipf-session
→ /about
→ /the-work
```

Use descriptive anchors.

Good:

```text
how an IPF session works
the five conditions of secure attachment
Evan's IPF training
```

Bad:

```text
click here
learn more
read this
```

---

# 38. Breadcrumbs

All nested informational pages:

```text
Home
>
Guides
>
What Happens During an IPF Session?
```

Use visible HTML breadcrumbs plus matching `BreadcrumbList` JSON-LD.

Do not show breadcrumbs on Home.

---

# 39. Visual/design direction

## Strategic reference

### Borrow from The Field

- large editorial typography;
- strong whitespace;
- low visual noise;
- premium photographic treatment;
- clear section rhythm;
- restrained color;
- high-quality text hierarchy;
- conceptual confidence.

The Field combines relatively minimal top-level navigation with courses, voices, media and practice sections without making the homepage feel like a directory. ([The Field][1])

### Borrow from Thorson

- direct language;
- audience recognition;
- simplicity;
- long-form copy allowed when meaningful;
- minimal primary navigation;
- prominent qualification of fit.

### Borrow from Attachment Repair

- strong topical hubs;
- abundant internal linking;
- useful resources;
- structured categories;
- repeatable article templates.

### Borrow from Mettagroup

- visible provenance;
- teacher/lineage connection;
- ecosystem authority.

### Borrow from Mindful Attachment

- explicit credentials;
- direct IPF landing page;
- question/intention-driven acquisition.

Its current navigation also demonstrates what _not_ to do: numerous quizzes and service categories compete simultaneously for attention. ([Mindful•Attachment•Coaching][16])

---

# 40. Layout dimensions

Suggested implementation constraints:

```text
Max shell width: 1200–1280 px
Long-form text width: 680–760 px
Wide evidence/table width: 960–1100 px

Desktop side padding: 32–48 px
Tablet: 24–32 px
Mobile: 18–24 px
```

Do not allow article body lines to span the full desktop viewport.

---

# 41. Typography

Use two fonts maximum.

Recommended design pattern:

```text
Editorial serif:
headlines / selected pull quotes

Neutral sans:
body / navigation / controls / metadata
```

Implement with `next/font`.

Next.js self-hosts fonts loaded through `next/font`, reducing external font requests and helping avoid font-related layout shifts. ([Next.js][17])

Do not load:

```text
6 font weights × 2 families
```

Suggested maximum:

```text
Regular
Medium
Semibold
```

plus one optional italic.

---

# 42. Images

All images should use `next/image` except where a technical reason requires native `<img>`.

Requirements:

- explicit intrinsic width/height;
- correct `sizes`;
- responsive variants;
- modern formats;
- appropriate alt text;
- empty alt for decorative images;
- no enormous source files;
- do not lazy-load the primary LCP hero image;
- lazy-load below-fold media.

Next.js's Image component provides responsive sizing, modern formats, lazy loading and layout-shift protections. ([Next.js][17])

---

# 43. Hero image rule

If using Evan's portrait in the hero:

```text
priority = true
fetchPriority = high
sizes = responsive
```

Do not use:

- background video;
- autoplay montage;
- parallax library;
- 5MB full-screen PNG;
- carousel.

The aesthetic should come from typography, photography and layout—not runtime effects.

---

# 44. Performance budgets

Hard performance targets:

| Metric  | Production target |
| ------- | ----------------: |
| LCP p75 |            < 2.5s |
| INP p75 |           < 200ms |
| CLS p75 |             < 0.1 |

These are current Core Web Vitals targets and should be monitored from real-user data, not only Lighthouse. ([Vercel][18])

Internal engineering budgets:

```text
Initial first-party JS:
target < 150 KB compressed where practical

Above-fold imagery:
target < 300 KB delivered on typical mobile

Third-party scripts:
minimum possible

Layout shift:
0 from images, fonts, embeds, banners
```

These latter values are internal budgets, not Google thresholds.

---

# 45. JavaScript strategy

Use Server Components by default.

Add `"use client"` only to components that genuinely require:

- state;
- event listeners;
- interactive forms;
- analytics interaction wrappers;
- accordion disclosure;
- audio controls.

Do not make every page a Client Component.

Most site pages should arrive as complete HTML.

---

# 46. Calendly integration

Preferred implementation:

**normal outbound CTA** rather than immediate embed.

Why:

- much lighter;
- faster LCP/INP;
- fewer third-party scripts;
- more predictable accessibility;
- easier analytics.

Example:

```text
Book a free consultation →
```

Only load an embedded scheduler after deliberate user interaction or on `/contact`.

If embedded:

```text
lazy-load
reserve height
do not allow layout shift
```

---

# 47. Contact form

Fields:

```text
Name
Email
Short message
```

Do not ask:

```text
Diagnosis
Trauma history
Medication
Mental-health condition
Clinical history
```

Add explicit microcopy:

> Please don't include sensitive medical or clinical information in this form.

Server:

```text
Zod validation
rate limiting
honeypot
Turnstile optional
server-side mail provider
no secrets exposed to client
```

Do not store contact submissions permanently unless there is an operational reason.

---

# 48. Environment variables

Server-only:

```text
SANITY_API_TOKEN
RESEND_API_KEY
INDEXNOW_KEY
CONTACT_TO_EMAIL
WEBHOOK_SECRET
```

Public:

```text
NEXT_PUBLIC_GA_ID
```

Only variables intentionally safe for the browser may use `NEXT_PUBLIC_`; Vercel/Next.js public-prefixed values are bundled into client code. ([Vercel][19])

Never place:

```text
API secret
CMS write token
mail secret
webhook secret
```

behind `NEXT_PUBLIC_`.

---

# 49. Accessibility requirements

Target:

```text
WCAG 2.2 AA
```

Minimum:

- semantic landmarks;
- one H1;
- logical heading order;
- skip-to-content link;
- keyboard navigation;
- visible focus states;
- sufficient contrast;
- labels for every form control;
- accessible error summaries;
- no color-only meaning;
- alt text policy;
- reduced-motion support;
- large tap targets;
- accessible accordions;
- descriptive link text.

Next.js's recommended ESLint setup includes `jsx-a11y` checks. ([Next.js][20])

This is also relevant to AI agent compatibility: OpenAI currently says its browser agent uses ARIA roles, labels and states to interpret interactive elements. ([OpenAI Help Center][11])

---

# 50. ESLint

Required:

```bash
pnpm add -D eslint eslint-config-next
```

Use Core Web Vitals config.

CI fails on:

```text
lint errors
TypeScript errors
build errors
```

Accessibility warnings should be reviewed, not ignored globally.

---

# 51. Analytics architecture

Use four evidence layers.

## Search

```text
Google Search Console
Bing Webmaster Tools
```

## Site behavior

Recommended:

```text
GA4
```

or another deliberate analytics system.

## Vercel performance

```text
Vercel Web Analytics
Vercel Speed Insights
```

## AI referrals

Track:

```text
chatgpt.com
perplexity.ai
copilot.microsoft.com
bing.com
other identified AI referrals
```

OpenAI automatically adds `utm_source=chatgpt.com` to ChatGPT Search referrals. ([OpenAI Help Center][11])

---

# 52. Analytics events

Create a controlled event dictionary.

```text
consultation_click
contact_submit
newsletter_submit

article_view
article_to_work_click
article_to_consultation_click

audio_play
audio_25
audio_50
audio_complete

event_registration_click
course_interest_click

external_authority_click
```

Properties:

```text
page_path
page_type
article_slug
cta_location
referrer_category
```

Do not send:

```text
message contents
email
name
health information
```

into analytics.

---

# 53. Consultation event

Example:

```ts
track('consultation_click', {
  page_path: pathname,
  cta_location: 'hero',
});
```

Every CTA should be distinguishable by location:

```text
hero
mid-page
footer
article
pricing
contact
```

This lets us learn where qualified conversions originate.

---

# 54. Search / GEO dashboard

Monthly dashboard should display:

### Google

```text
Organic clicks
Organic impressions
Queries
Indexed pages
Canonical issues
Google AI impressions/pages if available
```

### Bing

```text
Search performance
Indexed pages
AI total citations
Cited URLs
Grounding-query samples
Citation trends
```

Bing's 2026 AI Performance reporting exposes total citations, cited pages, grounding-query samples and page-level citation activity, while explicitly warning that citation counts do not equal ranking or authority. ([Bing Blogs][14])

### AI referrals

```text
ChatGPT sessions
Other AI referral sessions
Consultation conversions
Newsletter conversions
```

### Technical

```text
LCP
INP
CLS
5xx rate
404 rate
redirect errors
```

---

# 55. Content outcome metrics

Do not evaluate publishing by article count.

Track:

```text
non-brand impressions
unique query coverage
IPF hub impressions
guide clicks
citations
cited pages
grounding queries
consultation assists
external links earned
branded query growth
```

The SOP warns against metrics that reward volume or activity at the expense of the real outcome.

---

# 56. GEO/AEO content rules

Every major information page should answer:

```text
What is it?
Why does it matter?
How does it work?
What are the limitations?
Who is it relevant to?
What evidence exists?
Who is speaking?
Where does this information come from?
```

Avoid:

```text
keyword stuffing
50 near-identical FAQs
repetitive definitions
generic "ultimate guide" filler
manufactured statistics
unsourced clinical mechanisms
AI-generated summaries with no first-hand contribution
```

Google's current AI optimization guidance specifically prioritizes useful, non-commodity, experience-based content rather than special AI formatting. ([Google Developers][4])

---

# 57. Original-information requirement

Every guide should contain at least one element competitors cannot reproduce without Evan.

Examples:

```text
"In my experience facilitating IPF..."

"A difficulty I frequently see is..."

"One distinction that matters in practice is..."

"When someone has trouble visualizing, I usually..."

"What I wish people understood before beginning IPF..."

"Questions I recommend asking any facilitator..."
```

This is the content moat.

Attachment Repair can out-publish Evan.

It is much harder to out-publish **Evan's direct first-person expertise** if that expertise is documented clearly.

---

# 58. Free resource

After the initial authority hub is established, create:

```text
/resources/introductory-ipf-practice
```

Possible asset:

**A 15–20 minute introductory guided practice**

Page includes:

```text
What this exercise is
Who it is for
Audio player
Full transcript
Scope/safety statement
What to notice
Five-condition guide
Related article
Consultation CTA
```

Do not require email before allowing the user to hear the practice.

Optionally offer:

```text
Email me the transcript / follow-up guide
```

after utility has already been delivered.

Attachment Repair's large guided-meditation library demonstrates the value of providing useful assets rather than only explanatory sales copy. ([Attachment Repair][3])

---

# 59. Search-engine indexing policy

Every public strategic page:

```text
200
index
follow
self canonical
in sitemap
internally linked
```

Every preview/admin/API route:

```text
not indexable
```

Do not use robots.txt as a substitute for `noindex` on pages that need removal from the index.

---

# 60. 404 behavior

Create custom `/not-found.tsx`.

Must return an actual HTTP 404.

Copy:

```text
This page isn't here anymore.

You can start with:
Ideal Parent Figure Protocol
Work with Evan
Guides
Contact
```

Do not redirect every unknown URL to Home.

That creates soft-404 behavior and destroys migration diagnostics.

---

# 61. Security headers

Implement and test:

```text
Strict-Transport-Security
X-Content-Type-Options: nosniff
Referrer-Policy
Permissions-Policy
Content-Security-Policy
```

Do CSP first as:

```text
Content-Security-Policy-Report-Only
```

during staging.

Then enforce once required third-party hosts are known.

Expected allowlist may include:

```text
Calendly
analytics provider
Vercel
newsletter provider
CMS image CDN
Turnstile if used
```

Do not deploy an untested CSP that breaks forms or images.

---

# 62. Privacy / sensitive-content controls

Because prospective clients may discuss psychologically sensitive issues:

- minimize submitted data;
- never include contact-form contents in analytics;
- document form retention;
- avoid session replay tools on sensitive form pages unless explicitly configured to redact;
- redact all form fields if using a behavioral analytics product;
- require HTTPS everywhere;
- do not store intake data in a general CMS.

If formal intake is eventually required, use an appropriately vetted specialist system rather than a generic website form.

---

# 63. Newsletter architecture

Newsletter form:

```text
Email
Submit
```

Optional first name only if genuinely useful.

Capture source:

```text
homepage
article
event
footer
```

Do not show modal newsletter popups immediately on entry.

The desired brand is restrained and high-trust.

---

# 64. Preferred-source opportunity

Google now allows users to select publications/sites as preferred sources, including visibility treatment in AI Mode and AI Overviews in supported contexts. ([Google Developers][21])

This is **not launch-critical** for Evan.

Potential Phase 3 experiment:

```text
Follow EvanLeed.com in Google
```

only if Evan develops a meaningful publishing cadence.

Do not put it on the homepage before there is an actual editorial corpus worth following.

---

# 65. CI requirements

Every pull request:

```bash
pnpm install --frozen-lockfile
pnpm lint
pnpm typecheck
pnpm test
pnpm build
pnpm test:e2e
```

Suggested `package.json`:

```json
{
  "scripts": {
    "dev": "next dev",
    "build": "next build",
    "start": "next start",
    "lint": "eslint .",
    "typecheck": "tsc --noEmit",
    "test": "vitest run",
    "test:e2e": "playwright test"
  }
}
```

---

# 66. Automated SEO regression tests

Create Playwright/custom tests for:

### Every canonical public route

Assert:

```text
HTTP 200
exactly one <title>
description exists
exactly one H1
canonical exists
canonical uses www
canonical uses HTTPS
canonical has no trailing slash
robots does not contain noindex
```

### Global

Assert:

```text
/robots.txt returns 200
/sitemap.xml returns 200
sitemap URLs return 200
sitemap URLs self-canonicalize
no redirected URL appears in sitemap
no preview host is canonical
```

### Redirects

Test every legacy URL.

---

# 67. Structured-data QA

For every template:

```text
valid JSON
no duplicate @id
same visible title/date/name
canonical URL matches page
author @id resolves consistently
event date matches page
```

Do not deploy structured-data fields that contain information unavailable on the visible page merely to "improve schema."

---

# 68. Accessibility QA

Automated:

```text
axe
eslint jsx-a11y
```

Manual:

```text
keyboard-only navigation
screen-reader landmark check
mobile zoom
focus order
form-error behavior
accordion behavior
contrast
reduced motion
```

One representative user who did not build the site should complete:

```text
Find out what IPF is
Determine whether Evan is a therapist
Find Evan's training
Find session price
Book consultation
Find an article
Join newsletter
```

without developer guidance.

That directly matches the SOP's intended-user validation principle.

---

# 69. Performance QA

Run:

```text
Lighthouse CI
Vercel Speed Insights
real-device mobile tests
```

Test representative templates:

```text
Home
About
The Work
IPF hub
Guide
Event
Contact
```

Do not treat Lighthouse 100 as the objective.

Real-user Core Web Vitals are the production measure. ([Vercel][18])

---

# 70. Baseline before migration

Export before changing DNS:

### Search

```text
GSC 16-month export
Queries
Pages
Countries
Devices
Indexing state
Sitemap state
Core Web Vitals
```

### Analytics

```text
12 months landing pages
organic conversions
direct conversions
referrals
top exit pages
```

### Site

```text
full crawl
titles
descriptions
H1s
canonicals
status codes
internal links
image URLs
structured data
```

### Backlinks

At minimum capture known externally linked URLs.

### Content

Archive screenshots/PDF of every existing page.

This becomes the baseline evidence package.

---

# 71. Vercel project setup

Recommended environments:

```text
Production
Preview
Development
```

Branches:

```text
main → Production

feature/*
content/*
fix/*
→ Preview deployment
```

Production deploy only after PR approval.

Enable:

```text
Vercel Analytics
Vercel Speed Insights
deployment protection for previews
```

Vercel has first-class support for Next.js rendering, static generation, ISR and performance monitoring. ([Vercel][22])

---

# 72. CMS preview workflow

Content lifecycle:

```text
Draft
↓
Editorial review
↓
Evidence/claim review if needed
↓
Preview deployment / Draft Mode
↓
Publish
↓
Revalidation
↓
IndexNow notification
↓
Monitor
```

Do not let draft content become crawlable on an alternate public subdomain.

---

# 73. Cache strategy

### Static-ish pages

```text
Home
About
The Work
Who It's For
Scope
```

Generate statically and revalidate on CMS update.

### Articles

Static/ISR.

### Events

Static/ISR, but revalidate on event data changes.

### Contact

Static HTML plus dynamic form endpoint.

Avoid per-request SSR unless required.

---

# 74. Content revalidation

CMS publish webhook should:

```text
validate webhook
identify document type
revalidate affected page
revalidate related listing page
revalidate sitemap if new/removed URL
notify IndexNow
```

Example dependency:

```text
Guide updated
→ /guides/[slug]
→ /guides
→ potentially /ideal-parent-figure-protocol if linked module is dynamic
→ sitemap if updatedAt changes
```

---

# 75. Do not over-couple homepage to CMS collections

Homepage should not automatically render every new event/article.

Use curated references.

Otherwise publishing an article could unexpectedly alter homepage layout.

Have CMS fields such as:

```text
featuredGuide
featuredEvent
featuredTestimonialIds
```

---

# 76. Event-expiry automation

Nightly scheduled job or render-time computed state:

```ts
const hasEnded = new Date(event.endDate) < new Date();
```

If ended:

```text
disable registration CTA
show concluded state
remove "open" badge
update structured data
```

No event banner should require a human to remember the date passed.

---

# 77. Content publishing quality gate

An article cannot publish until:

```text
Title complete
Description complete
H1 complete
Direct answer complete
Author set
Published date set
Canonical slug set
Internal links present
Relevant sources present
Claims reviewed
Scope statement added where necessary
OG image set
Related guides selected
CTA selected
```

CMS should validate required fields.

---

# 78. Research page special gate

`/guides/ipf-research-evidence` cannot publish until:

- primary literature reviewed;
- each substantive research claim cited;
- study design correctly described;
- sample/population described where relevant;
- outcomes not generalized beyond evidence;
- limitations explicitly stated;
- "evidence" separated from Evan's practitioner experience.

This is a higher editorial control tier than an ordinary article.

---

# 79. Scope / safety page

## URL

```text
/scope-and-safety
```

## H1

```text
Scope of IPF Facilitation
```

Cover:

```text
What Evan provides
What he does not provide
Relationship to psychotherapy
Working alongside clinicians
Group-program limitations
Crisis support boundary
Confidentiality limitations of website contact
```

Keep wording conservative.

This page can be linked whenever an article touches:

```text
trauma
diagnosis
crisis
treatment
psychotherapy
clinical outcomes
```

---

# 80. About-page authority graph

The developer should explicitly connect:

```text
Evan Leed
   ↓
Daniel P. Brown
   ↓
Ideal Parent Figure Protocol

Evan Leed
   ↓
George Haas
   ↓
Mettagroup
```

This can be displayed visually but must remain normal semantic HTML.

Do not turn this into a canvas-only diagram with inaccessible text.

---

# 81. External authority links

Where verified:

```text
Mettagroup profile
teacher references
primary research publications
podcast/interview appearances
professional profiles
```

Open external links normally.

Do not use `nofollow` on legitimate editorial citations merely because they leave the site.

---

# 82. Social/entity consistency task

Before launch, verify external profiles use the same:

```text
Name
Primary domain
Role
Biography
Session format
Pricing if displayed
Location if displayed
Training description
```

Any outdated directory price or biography should be updated where possible.

---

# 83. Image content strategy

Create a small purposeful image library:

```text
Primary Evan portrait
Secondary natural portrait
Work / contemplative environment
Simple editorial abstractions
Event-specific images
Article OG system
```

Do not use generic:

```text
sad person staring out window
hands holding heart
therapy couch
stock wellness yoga poses
```

The desired audience is sophisticated enough that generic therapy stock photography will materially weaken positioning.

---

# 84. Open Graph image system

Build dynamic OG images for articles.

Template:

```text
Evan Leed

[Article title]

Ideal Parent Figure Protocol
```

Use:

```text
1200 × 630
```

with strong readability.

Do not pack logos and decorative elements around the title.

---

# 85. CTA hierarchy

Only three meaningful CTA types sitewide:

### Primary

```text
Book a free consultation
```

### Educational

```text
Understand IPF
```

### Retention

```text
Join the newsletter
```

Event pages add:

```text
Register
```

Do not invent a different CTA phrase for every section.

---

# 86. Mobile navigation

Mobile nav order:

```text
IPF
Work With Me
Who It's For
About
Guides
Events

Book a Call
```

CTA button visually distinct but not oversized.

No nested three-level mega-menu.

---

# 87. Footer provenance

Footer can state:

```text
Evan Leed
Ideal Parent Figure facilitator
Online sessions
```

Then:

```text
IPF facilitation and coaching, not psychotherapy.
```

Do not place a long medical disclaimer in tiny gray 10px text.

---

# 88. Technical SEO definition of done

Before production acceptance:

```text
[ ] One canonical hostname
[ ] HTTPS
[ ] No trailing-slash duplicates
[ ] Every intended public route 200
[ ] Every removed legacy URL accounted for
[ ] No redirect chain
[ ] No sitemap redirects
[ ] Self-canonicals
[ ] Unique titles
[ ] Unique descriptions
[ ] One clear H1
[ ] Rendered primary content
[ ] robots.txt correct
[ ] sitemap correct
[ ] OAI-SearchBot policy deliberate
[ ] GPTBot policy deliberate
[ ] Production index/follow
[ ] Preview noindex
[ ] JSON-LD valid
[ ] No schema/visible-content conflicts
[ ] Internal links crawlable
[ ] Images have dimensions
[ ] Accessibility pass
[ ] Analytics verified
[ ] GSC verified
[ ] Bing verified
[ ] Core Web Vitals instrumentation live
```

---

# 89. Launch state model

Following the SOP:

```text
Not Ready
↓
Build
↓
Content Migration
↓
Technical QA
↓
SEO QA
↓
Stakeholder Review
↓
Pilot Ready
↓
Production Deployment
↓
High-Frequency Monitoring
↓
Validated
↓
Steady State
```

Abnormal states:

```text
At Risk
Paused
Rolling Back
Failed
Completed With Exception
```

The SOP requires abnormal and terminal states in addition to the happy path.

---

# 90. Launch stop conditions

Immediate stop/rollback if any of the following occurs:

| Condition                                    | Decision                          |
| -------------------------------------------- | --------------------------------- |
| Production homepage has `noindex`            | Rollback                          |
| robots.txt blocks strategic site             | Rollback                          |
| Primary domain returns 5xx                   | Rollback                          |
| Important legacy pages return unintended 404 | Contain/fix                       |
| Canonicals point to Preview/Vercel domain    | Rollback                          |
| Canonicals point to wrong pages              | Rollback                          |
| Redirect loop                                | Fix immediately                   |
| Sitemap contains Preview host                | Stop sitemap submission           |
| Core content absent from rendered HTML       | Rollback affected template        |
| Analytics completely missing                 | Fix before performance evaluation |
| Contact/booking path broken                  | Rollback or emergency fix         |
| Event pricing/date materially incorrect      | Remove affected promotion         |

---

# 91. Do not rollback for early ranking noise

Organic rankings may fluctuate after migration.

Do not rollback a technically correct migration because:

```text
impressions decline for 48 hours
one keyword moves down
an AI citation disappears in one test
```

Performance evaluation needs a meaningful window.

Recommended:

```text
Technical validation:
minutes → 72 hours

Indexing validation:
days → 2 weeks

Search-performance evaluation:
28+ days

Strategic content assessment:
60–90+ days
```

unless a deterministic technical failure is found.

This directly implements the SOP principle of fast feedback without reflexive reaction.

---

# 92. Launch timeline

## T-21 to T-14

```text
Legacy crawl
Search baseline
Analytics baseline
URL inventory
Backlink URL inventory
Content archive
CMS model complete
Redirect sheet begun
```

## T-14 to T-7

```text
Core pages implemented
Metadata implemented
Schema implemented
Robots/sitemap implemented
Forms implemented
Analytics implemented
Content migrated
```

## T-7

**URL freeze.**

No new URL restructuring after this point except defects.

## T-7 to T-3

```text
Full staging crawl
Mobile QA
Accessibility QA
Redirect testing
Structured-data QA
Performance QA
Content sign-off
Claims review
```

## T-2

```text
Production environment variables
Vercel domains
DNS plan
Rollback rehearsal
Final crawl comparison
```

## T-1

Record final Squarespace baseline.

## T0

Deploy.

---

# 93. Launch-hour checklist

Within first 15 minutes:

```text
Homepage 200
About 200
The Work 200
IPF hub 200
Contact 200
robots.txt 200
sitemap.xml 200
canonical host correct
forms work
Calendly works
```

Within first hour:

```text
crawl top 20 URLs
test every high-value redirect
test mobile
test analytics
test schema
inspect response headers
```

Within four hours:

```text
full production crawl
compare URL counts
check 404s
check canonicals
check sitemap
submit sitemap
```

---

# 94. Post-launch cadence

## Day 1

```text
crawl
5xx
404
redirects
analytics
conversion
robots
canonical
```

## Day 3

```text
GSC inspection samples
Bing inspection
sitemap processing
IndexNow processing/errors
```

## Day 7

```text
indexed URL trend
query exposure
organic landing traffic
technical anomalies
```

## Day 14

```text
canonical selection
index coverage
top query change
AI citation baseline
```

## Day 28

Formal migration effectiveness review.

## Day 60

Content-cluster assessment.

## Day 90

Strategic SEO/GEO review.

---

# 95. Bing GEO measurement

Once enough data accumulates, review:

```text
Cited pages
Citation counts
Grounding-query samples
Topic concentration
Pages indexed but rarely cited
```

Do not interpret raw citation count as ranking.

Microsoft explicitly cautions against that interpretation. ([Bing Blogs][14])

Use grounding-query data to inform content improvement:

Example:

```text
grounding queries repeatedly mention:
"five conditions secure attachment"

but Evan only ranks/cites weakly

→ deepen that guide
→ improve evidence
→ add internal links
→ verify freshness
```

---

# 96. ChatGPT measurement

Allow `OAI-SearchBot` if Evan wants ChatGPT Search discovery. ([OpenAI Help Center][11])

GA4 segment:

```text
utm_source = chatgpt.com
```

Track:

```text
landing page
consultation click
newsletter signup
session quality
conversion rate
```

Do not expect Search Console-style query data from ChatGPT.

---

# 97. Google AI measurement

Use Google's first-party generative-AI Search reporting where available.

Do not trust vendors claiming access to secret Google AI ranking scores.

Google's 2026 documentation explicitly warns against third-party claims of internal ranking data and recommends focusing on high-quality, unique content and first-party performance reporting. ([Google Developers][4])

---

# 98. Competitive success criterion

We are **not** trying to make Evan's site look more like Attachment Repair.

We are trying to achieve:

```text
The Field
premium editorial confidence

+

Daniel Thorson
audience precision

+

Attachment Repair
topic architecture and useful resources

+

Mettagroup
provenance and ecosystem legitimacy

+

Mindful Attachment
explicit IPF intent capture
```

while maintaining a substantially simpler interface.

---

# 99. What the developer should explicitly reject

If requested later, push back on:

```text
keyword-stuffed footer
500 autogenerated pages
one page per tiny keyword variation
llms.txt presented as Google GEO optimization
hidden AI text
FAQ schema as ranking tactic
animated canvas hero
autoplay background video
six analytics tools
heatmap/session replay on sensitive forms
homepage mega-menu
client-side rendering of core article text
duplicate city pages without real local purpose
AI-generated research citations
```

---

# 100. Future content roadmap after first 10 guides

Only after the first cluster performs.

Potential second cluster:

```text
Internal working models in attachment
Attachment and exploration
Attachment and collaboration
Why insight sometimes doesn't change relational patterns
IPF for longtime meditators
Attachment security and contemplative practice
Common problems during IPF imagery
What to do when an ideal parent feels unbelievable
How to work with resistance in imagery
What secure relating feels like in everyday life
```

Potential third cluster:

```text
Original practitioner essays
Audio practices
Case-pattern essays with anonymization
Interviews with teachers/practitioners
Research commentary
```

---

# 101. Free-practice roadmap

Start with five eventually:

```text
Safety
Attunement
Soothing
Delight
Support for exploration
```

Each:

```text
Landing page
Audio
Transcript
Context
Limitations
Related guide
IPF hub link
Consultation CTA
```

This gives Evan a useful corpus without attempting Attachment Repair's sheer scale.

---

# 102. Open owner decisions before implementation

The developer should not guess these.

Evan must confirm:

| Decision                    | Required before          |
| --------------------------- | ------------------------ |
| Preferred `www` host        | Production configuration |
| Current session price       | Copy/content freeze      |
| Sliding-scale minimum       | Copy/content freeze      |
| Consultation duration       | Copy/content freeze      |
| Current Calendly URL        | QA                       |
| Contact email               | QA                       |
| Newsletter provider         | Integration              |
| Exact scope statement       | Content approval         |
| GPTBot allow/deny           | Robots launch            |
| Verified external profiles  | Person schema            |
| Approved biography          | About launch             |
| Training wording            | About launch             |
| Testimonials/public consent | Content launch           |
| Current event/course status | Migration                |
| Claims Evan wants retained  | Editorial review         |
| Privacy policy              | Launch                   |
| Research citations          | Research-guide publish   |

---

# 103. Developer deliverables

The build contractor should deliver:

```text
Git repository
Vercel project
Production domain configuration
CMS project/schema
README
Environment-variable inventory
Redirect manifest
Legacy URL manifest
Component inventory
Analytics event dictionary
Claims/source register
SEO metadata matrix
Schema implementation
robots implementation
sitemap implementation
IndexNow implementation
Accessibility report
Performance report
Production crawl report
Migration comparison report
Rollback instructions
Content-editor guide
```

---

# 104. README requirements

README must include:

```text
Local setup
Required Node version
Package manager
Environment variables
CMS setup
Development command
Build command
Tests
Preview workflow
Publishing workflow
Revalidation behavior
Redirect editing
Adding a guide
Adding an event
Updating price/settings
Schema architecture
Analytics architecture
Deployment process
Rollback process
```

No critical operational knowledge should exist only in the developer's memory.

---

# 105. Content-editor guide

Evan should receive a short separate work instruction explaining:

### How to

```text
edit a page
publish a guide
schedule/publish an event
close registration
change pricing
update a source
feature an article
update the homepage
add a testimonial
```

### What not to do

```text
change URLs casually
create duplicate pages
manually write rates in rich text
manually type event dates into unrelated pages
publish medical claims without evidence review
paste arbitrary script tags
```

---

# 106. Definition of done

The rebuild is complete only when all of the following are true.

## Product

```text
[ ] Site communicates Evan's positioning clearly
[ ] Target visitor can identify themselves
[ ] Consultation path is obvious
[ ] IPF hub is substantive
[ ] About provides verified provenance
```

## Technical

```text
[ ] Production is on Vercel
[ ] Current stable Next.js App Router
[ ] TypeScript
[ ] Server-rendered core content
[ ] CMS operational
[ ] Preview workflow operational
```

## SEO

```text
[ ] Legacy URL map completed
[ ] Redirects validated
[ ] Self-canonicals
[ ] Canonical host normalized
[ ] XML sitemap
[ ] robots.txt
[ ] Unique titles/H1s
[ ] Rendered crawl completed
[ ] Search Console verified
[ ] Bing Webmaster verified
```

## GEO/AEO

```text
[ ] OAI-SearchBot policy intentional
[ ] Article direct-answer component
[ ] Evidence/source component
[ ] Author entity architecture
[ ] Bing AI baseline plan
[ ] ChatGPT referral tracking
```

## Performance

```text
[ ] No uncontrolled layout shift
[ ] Vercel Speed Insights live
[ ] Mobile performance tested
[ ] Heavy third-party scripts deferred
```

## Accessibility

```text
[ ] Keyboard pass
[ ] Screen-reader structural pass
[ ] Axe issues resolved/reviewed
[ ] Forms accessible
[ ] Focus behavior correct
```

## Governance

```text
[ ] Pricing centralized
[ ] Event data centralized
[ ] Scope statement centralized
[ ] Claims register implemented
[ ] Rollback rehearsed
[ ] Launch evidence retained
[ ] Post-launch review scheduled
```

---

# 107. Final implementation priority

If the developer needs a strict build sequence, use this:

### Phase 1 — foundation

```text
Repo
Vercel
CMS
design system
site config
navigation
metadata
robots
sitemap
schema utilities
analytics
```

### Phase 2 — migration-critical pages

```text
Home
About
The Work
Contact
Retreat legacy URL
Privacy
Scope/Safety
```

### Phase 3 — positioning

```text
Who This Is For
```

### Phase 4 — authority

```text
Ideal Parent Figure Protocol hub
Guides hub
```

### Phase 5 — conversion/content systems

```text
Newsletter
Event model
Course model
Article model
Internal-link system
```

### Phase 6 — migration

```text
Legacy redirects
Full crawl
QA
DNS
Launch
```

### Phase 7 — GEO/AEO expansion

```text
Guides #2–10
Free practice
Research page
AI citation measurement
```

---

# 108. The architectural principle to preserve

The developer should understand the strategic reason behind all of this.

Evan's current site already contains strong material: direct IPF specialization, one-to-one service information, concrete pricing, FAQs, first-person story, testimonials and direct training claims. But much of it is duplicated between Home and About, mixed with temporary promotions, and concentrated into only a handful of URLs. ([Evan Leed][5])

The rebuild should transform:

```text
small brochure site
+
temporary event pages
+
duplicated biography
```

into:

```text
a compact premium practitioner site
+
a structured IPF knowledge base
+
a documented first-party authority graph
+
a measurable search/AI acquisition system
```

The central competitive bet is:

> **Do not beat Attachment Repair by becoming a larger Attachment Repair. Build the smaller, clearer, more authoritative and more intellectually trustworthy source.**

The technical architecture should make that advantage durable: **one source of truth, stable canonical URLs, server-rendered content, structured provenance, evidence-backed claims, fast pages, accessible interaction, controlled publishing, and measurable retrieval/citation outcomes.**

That combination follows both the competitive evidence and the operating logic in the SOP: outcomes before activities, evidence before opinion, stable controls with adaptable implementation, localized change, explicit dependencies, reversible rollout, and measurable effectiveness.

[1]: https://thefield.us/ 'The Field — Classical methods, contemporary practice'
[2]: https://www.dthorson.com/ 'Daniel Thorson — The Most Important Work of Your Life'
[3]: https://attachmentrepair.com/ 'Attachment Repair – Heal Your Attachment With Meditation'
[4]: https://developers.google.com/search/docs/fundamentals/ai-optimization-guide?hl=ru&utm_source=chatgpt.com 'Руководство Google по оптимизации для функций на основе генеративного ИИ в Google Поиске | Центр Google Поиска  |  Documentation  |  Google for Developers'
[5]: https://www.evanleed.com/ 'Evan Leed | Trauma-Informed IPF Facilitator'
[6]: https://nextjs.org/learn/dashboard-app/adding-metadata?utm_source=chatgpt.com 'App Router: Adding Metadata | Next.js'
[7]: https://www.mettagroup.org/ 'Meditation x Attachment | Mettagroup'
[8]: https://nextjs.org/learn/seo/status-codes?utm_source=chatgpt.com 'SEO: What are HTTP Status Codes? | Next.js'
[9]: https://developers.google.com/search/docs/crawling-indexing/canonicalization?hl=en&utm_source=chatgpt.com 'What is URL Canonicalization | Google Search Central  |  Documentation  |  Google for Developers'
[10]: https://www.evanleed.com/the-work 'The Work | Ideal Parent Figure Protocol & Attachment Repair — Evan Leed'
[11]: https://help.openai.com/en/articles/12627856-publishers-and-developers-faq?utm_source=chatgpt.com 'Publishers and Developers - FAQ | OpenAI Help Center'
[12]: https://developers.google.com/search/updates?utm_source=chatgpt.com "Latest Google Search Documentation Updates | Google Search Central  |  What's new  |  Google for Developers"
[13]: https://blogs.bing.com/webmaster/July-2025/Keeping-Content-Discoverable-with-Sitemaps-in-AI-Powered-Search?utm_source=chatgpt.com 'Keeping Content Discoverable with Sitemaps in AI Powered Search...'
[14]: https://blogs.bing.com/webmaster/February-2026/Introducing-AI-Performance-in-Bing-Webmaster-Tools-Public-Preview?utm_source=chatgpt.com 'Introducing AI Performance in Bing Webmaster Tools Public Preview ...'
[15]: https://developers.google.com/search/docs/fundamentals/ai-optimization-guide?hl=it&utm_source=chatgpt.com "Guida di Google all'ottimizzazione per le funzionalità di AI generativa nella Ricerca Google | Google Search Central  |  Documentation  |  Google for Developers"
[16]: https://www.mindfulattachmentcoaching.com/ 'Online Mindfulness Coach'
[17]: https://nextjs.org/learn/dashboard-app/optimizing-fonts-images?utm_source=chatgpt.com 'App Router: Optimizing Fonts and Images | Next.js'
[18]: https://vercel.com/academy/nextjs-foundations/core-web-vitals-and-measurement?utm_source=chatgpt.com 'Core Web Vitals + Measurement | Vercel Academy'
[19]: https://vercel.com/academy/nextjs-foundations/env-and-security?utm_source=chatgpt.com 'Environment and Security | Vercel Academy'
[20]: https://nextjs.org/learn/dashboard-app/improving-accessibility?utm_source=chatgpt.com 'App Router: Improving Accessibility | Next.js'
[21]: https://developers.google.com/search/docs/appearance/preferred-sources?authuser=451499271&utm_source=chatgpt.com 'Guide to Preferred Sources in Google Search for Web Publishers | Google Search Central  |  Documentation  |  Google for Developers'
[22]: https://vercel.com/frameworks/nextjs?utm_source=chatgpt.com 'Next.js on Vercel'
