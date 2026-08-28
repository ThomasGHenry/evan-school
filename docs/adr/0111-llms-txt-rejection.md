---
status: accepted
date: 2026-08-28
tags: [seo, geo]
---

# 0111. llms.txt not implemented

## Context

PRD §8 listed `llms.txt` as part of the settled GEO stack, and ADR 0104
(original) included it as a Phase 2 deliverable at `apps/web/public/llms.txt`.

In June 2026, Google clarified that its Search systems do not read or act on
`llms.txt`. The file has no standardised specification and no confirmed effect
on Google AI Overviews, ChatGPT live retrieval, Perplexity citations, or Bing
Copilot grounding. seo.md §30 explicitly rejects it and lists it in §99 as a
practice to avoid.

The AI discoverability goals of this project — appearing in AI-generated answers,
being cited in ChatGPT and Perplexity responses — are served by JSON-LD
structured data, static-first rendering, and `robots.ts` AI crawler permissions.
These are confirmed effective mechanisms; `llms.txt` is not.

## Decision

`llms.txt` is not implemented. No file is created at `apps/web/public/llms.txt`
or any other path.

## Consequences

- GitHub issue #40 (Implement llms.txt) closed as not planned
- ADR 0104 updated to remove `llms.txt` from scope
- AI discoverability is served by JSON-LD schemas (ADR 0104), `robots.ts`
  (ADR 0120), and static-first rendering
- If `llms.txt` achieves confirmed effectiveness with major AI systems in future,
  this decision should be revisited via a new ADR
