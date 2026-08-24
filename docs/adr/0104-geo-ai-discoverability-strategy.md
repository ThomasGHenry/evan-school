---
status: accepted
date: 2026-08-24
tags: [seo, geo, content, architecture]
implementation: apps/web/public/llms.txt
---

# 0104. GEO / AI Discoverability Strategy

## Context

PRD §2 lists "Discoverability — rank in Google, appear in AI-generated answers
(ChatGPT, Perplexity, etc.)" as a primary goal. PRD §8 marks the GEO stack as
Settled: Next.js metadata API, `llms.txt`, `sitemap.xml`, `robots.txt`,
OpenGraph, JSON-LD.

The competitive context sharpens this decision: the current #1 result on LLM
searches for IPF Protocol and attachment repair content (per Evan, issue #39)
is a practitioner with fabricated credentials. Evan is a legitimate, trained
practitioner with a verified lineage. LLMs weight explicit, first-party
credential signals in source documents. A deliberate GEO strategy can displace
a fraudulent incumbent.

Three layers of AI discoverability are in scope:

1. **`llms.txt`** — self-description file for LLM crawlers; not yet standardized
   but respected by ChatGPT, Perplexity, and others. States who Evan is, what
   the site contains, and what content is most citable.
2. **JSON-LD structured data** — machine-readable schema that surfaces in Google
   rich results and is extracted by LLM crawlers as high-confidence structured
   facts. `Person`, `Course`, `Article`, `WebSite` schemas.
3. **Static-first public pages** — all public routes are SSG (Next.js static
   generation). Crawlers see fully-rendered HTML, not a blank JS shell.

## Decision

Implement all three layers as Phase 2 deliverables (issues #40, #41, #42),
with static-first rendering already enforced by the stack choice (ADR 0003).

**`llms.txt` content strategy:**
- Structured description of Evan's credentials, lineage, and practice area
- Explicit links to blog index, course catalog, and about section
- No listing of protected or admin routes
- Plain prose optimized for LLM extraction, not keyword density

**JSON-LD schemas per page type:**
- All pages: `WebSite` with `potentialAction: SearchAction`
- Landing page: `Person` (Evan's name, title, credentials, social links)
- `/courses/[slug]`: `Course` (name, provider, description, price, startDate)
- `/blog/[slug]`: `Article` (headline, author, datePublished, dateModified)
- No schema on auth-gated routes (`/dashboard`, `/admin`, `/resources`)

**AI crawler permissions (`robots.txt`):**
- Allow all AI crawlers by default: `GPTBot`, `ClaudeBot`, `PerplexityBot`,
  `CCBot`, `anthropic-ai`, `Googlebot`
- Disallow: `/admin`, `/dashboard`, `/checkout`, `/account`
- Do not disallow `/blog` or `/courses` — these are the citation targets

**Schema content sourcing:**
- MVP: schema fields populated from gray-matter content pipeline (ADR 0103)
- Phase 3: same `getPageContent` interface, Prisma replaces file reads —
  JSON-LD generation code does not change

## Consequences

- `apps/web/public/llms.txt` — static file, ships with build
- `apps/web/public/robots.txt` — extends issue #30 with AI bot entries
- `apps/web/src/app/layout.tsx` — `WebSite` schema added to root layout
- Per-page `generateMetadata()` and JSON-LD `<Script>` in course and blog
  page components
- Blog and course content pages must be SSG (enforced by not using
  `export const dynamic = 'force-dynamic'`)
- Evan must supply credential copy for `llms.txt` and `Person` schema before
  Phase 2 ships — this is a content dependency, not a build dependency
- No third-party GEO service required; all signals are first-party and
  version-controlled
