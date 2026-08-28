---
status: accepted
date: 2026-08-28
tags: [seo, geo, content, architecture]
implementation: apps/web/src/app/robots.ts
---

# 0104. GEO / AI Discoverability Strategy

## Context

PRD §2 lists discoverability — rank in Google, appear in AI-generated answers
(ChatGPT, Perplexity, etc.) — as a primary goal. The competitive context is
specific: the current top LLM result for IPF Protocol and attachment repair
content is a practitioner with fabricated credentials. Evan is a legitimate,
trained practitioner with a verified lineage. LLMs weight explicit, first-party
credential signals. A deliberate GEO strategy can displace a fraudulent incumbent.

seo.md (2026-08-28) is the authoritative SEO/GEO/AEO specification for this
project. This ADR records the architectural decisions derived from it.

Three layers of AI discoverability are in scope:

1. **JSON-LD structured data** — machine-readable schema extracted by LLM
   crawlers as high-confidence structured facts and surfaced in Google rich
   results.
2. **Static-first public pages** — all public routes are SSG. Crawlers see
   fully-rendered HTML, not a blank JS shell.
3. **AI crawler permissions (`robots.ts`)** — generated Next.js Metadata Route
   controlling which bots access which routes.

`llms.txt` is explicitly out of scope. Google clarified in June 2026 that its
Search systems ignore `llms.txt`. It is not implemented. See ADR 0111.

## Decision

### JSON-LD schema inventory

Schema types per page:

| Route | Schemas |
|---|---|
| All pages | `WebSite` with `potentialAction: SearchAction` |
| `/` | `Person` — sitewide entity anchor `@id: https://www.evanleed.com/#evan-leed` |
| `/about` | `ProfilePage` + `Person` |
| `/the-work` | `Service` |
| `/guides` | `CollectionPage` |
| `/guides/[slug]` | `Article` — author references `/#evan-leed` |
| `/courses/[slug]` | `Course` (name, provider, description, price, startDate) |
| All nested pages | `BreadcrumbList` (visible HTML + matching JSON-LD) |

`FAQPage` schema is not implemented — deprecated by Google in May 2026. Semantic
HTML question/answer structure is used instead.

No structured data on auth-gated routes (`/dashboard`, `/admin`, `/resources`,
`/account`).

### AI crawler policy (`src/app/robots.ts`)

Generated via Next.js Metadata Route API, not a static `public/robots.txt`.

Allowed crawlers (all routes not explicitly disallowed): `Googlebot`,
`OAI-SearchBot`, `GPTBot`, `ClaudeBot`, `PerplexityBot`, `CCBot`,
`anthropic-ai`.

Disallowed for all crawlers: `/admin`, `/dashboard`, `/checkout`, `/account`,
`/api`.

CSS, JS, and images are not blocked — crawlers require them for rendering.

### Static-first rendering

All public routes (`/`, `/about`, `/the-work`, `/guides`, `/guides/[slug]`,
`/courses`, `/courses/[slug]`) are statically generated at build time. Auth-gated
routes use server-side rendering with Payload token verification.

### Content routes

The public content section is `/guides` and `/guides/[slug]` — not `/blog`. The
service page is `/the-work` — not `/work` or `/1-1`.

## Consequences

- `src/app/robots.ts` is the sole robots policy file — no `public/robots.txt`
- All JSON-LD implemented as inline `<script type="application/ld+json">` in
  page `<head>` via Next.js `metadata` or explicit script tags
- Sitewide `Person` entity `@id` (`/#evan-leed`) must be consistent across all
  `Article` author references
- `llms.txt` is not created — see ADR 0111
- Public content routes use `/guides` slug, not `/blog`
- ADR 0111 documents the `llms.txt` rejection
- ADR 0120 documents the full robots policy rationale
