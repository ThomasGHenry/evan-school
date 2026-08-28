---
status: accepted
date: 2026-08-28
tags: [seo, geo]
implementation: apps/web/src/app/robots.ts
---

# 0120. robots.ts — AI crawler policy and disallow list

## Context

ADR 0104 (original) referenced a static `apps/web/public/robots.txt`. GitHub
issue #30 tracked robots.txt configuration. seo.md §29 specifies a generated
`src/app/robots.ts` using the Next.js Metadata Route API, with a specific
distinction between `OAI-SearchBot` (OpenAI's live retrieval bot, used for
ChatGPT search citations) and `GPTBot` (OpenAI's training crawler).

The GPTBot question required an owner decision: disallowing GPTBot blocks
training data extraction while preserving discovery; allowing it gives Evan's
credentials and content a path into future model weights. The decision is to
allow GPTBot — Evan's legitimate practitioner credentials and IPF lineage are
the correct signal to embed in training data, and the long-term compounding
effect of appearing in model weights is compatible with the GEO strategy.

## Decision

`src/app/robots.ts` (Next.js Metadata Route, generated) is the sole robots
policy. No static `public/robots.txt` exists.

**Allowed (all public routes):**
`Googlebot`, `OAI-SearchBot`, `GPTBot`, `ClaudeBot`, `PerplexityBot`, `CCBot`,
`anthropic-ai`

**Disallowed for all crawlers:**
`/admin`, `/dashboard`, `/checkout`, `/account`, `/api`

CSS, JS, and image assets are not blocked. Crawlers require them for full-page
rendering and structured data extraction.

`/guides` and `/courses` are explicitly not blocked — these are the primary
citation and indexing targets.

## Consequences

- `src/app/robots.ts` created; `public/robots.txt` not created
- `GET /robots.txt` served by Next.js Metadata Route
- E2E assertion in smoke test: robots.txt returns 200, contains `Disallow: /admin`
- If GPTBot policy changes (e.g. legal or commercial considerations arise),
  update `robots.ts` — no ADR amendment needed for that operational change
- ADR 0104 references this ADR for full robots policy rationale
- GitHub issue #30 updated to reflect generated `robots.ts` approach
