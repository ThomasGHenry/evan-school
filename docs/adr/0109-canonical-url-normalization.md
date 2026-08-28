---
status: accepted
date: 2026-08-28
tags: [architecture, seo]
implementation: next.config.ts
---

# 0109. Canonical URL and host normalization

## Context

The site will be served at `evanleed.com`. Without explicit normalization, the
same content is reachable at `evanleed.com`, `www.evanleed.com`,
`evanleed.com/path/`, and `www.evanleed.com/path/` — four URLs per page. Google
treats each as a distinct URL, splitting link equity and creating duplicate
content signals. Canonical tags alone are insufficient; the redirect must be
enforced at the edge so crawlers and browsers never receive a 200 response on a
non-canonical host or trailing-slash variant.

## Decision

`https://www.evanleed.com` is the canonical host. All other host variants
redirect to it.

**Apex → www:** Configured in Vercel Domains (not middleware). `evanleed.com`
returns a 308 permanent redirect to `www.evanleed.com` for every path. This is
handled at the CDN layer — Next.js middleware never runs for apex requests.

**Trailing slash:** `next.config.ts` sets `trailingSlash: false`. Next.js
automatically redirects any `/path/` to `/path`. The redirect is 308.

**Canonical tags:** Every page includes `<link rel="canonical">` pointing to the
www canonical URL. Implemented via Next.js `metadata.alternates.canonical` in
each route's metadata export, or via a shared layout metadata base.

**Sitemap URLs:** All entries use `https://www.evanleed.com` — no apex, no
trailing slash.

## Consequences

- Vercel Domains config: apex domain added as redirect to www (one-time setup,
  done in `infra/platform/` OpenTofu module)
- `next.config.ts`: `trailingSlash: false` (default, explicit for clarity)
- All `metadata.alternates.canonical` values use `https://www.evanleed.com`
- `NEXT_PUBLIC_SITE_URL=https://www.evanleed.com` added to env schema for
  canonical URL construction at runtime
- Smoke test assertion: apex redirect returns 308 to www equivalent
- GitHub issue #47 tracks implementation
