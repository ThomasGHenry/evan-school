---
status: accepted
date: 2026-08-24
tags: [testing, ci]
implementation: apps/web-e2e/playwright.config.ts
---

# 0102. Visual Regression Strategy: Playwright Multi-Viewport Assertions

## Context

The site will ship 19 routes across 3 viewport targets (mobile 390px, tablet 768px,
desktop 1280px) — 57 views total. We need automated CI detection of egregious UX
regressions: a CTA missing entirely, a nav bar absent from a route, a primary call to
action pushed below the viewport fold by a copy change.

Pixel-perfect visual diffing (screenshot snapshots) was evaluated and rejected:
- Any CSS tweak, font-rendering delta, or anti-aliasing difference fails the diff
- 57 snapshot files must be manually approved on every intentional visual change
- CI becomes a maintenance burden rather than a safety net

Third-party visual review services (Percy, Chromatic) were evaluated and rejected:
- Both require a human to approve/reject each diff before the gate passes
- Manual review step defeats the "automated pass/fail" requirement
- Free tiers would likely fit usage volume, but the workflow model is wrong

The project already has `@playwright/test@^1.50.0` in `apps/web-e2e/` and a working
`smoke.spec.ts` using aria-role selectors. Zero new dependencies are required.

## Decision

Playwright element-existence and above-fold position assertions across three viewport
projects. Two assertion primitives cover both failure modes:

1. `expect(locator).toBeVisible()` — catches "element absent from DOM or hidden"
2. `getBoundingClientRect().bottom < viewportSize().height` — catches "element
   rendered below the fold"

Three Playwright projects replace the single Chromium project:

```ts
projects: [
  { name: 'mobile',  use: { ...devices['iPhone 12'] } },           // 390×844
  { name: 'tablet',  use: { viewport: { width: 768, height: 1024 } } },
  { name: 'desktop', use: { ...devices['Desktop Chrome'] } },      // 1280×720
],
```

A shared `assertAboveFold(page, locator)` utility in
`apps/web-e2e/src/above-fold.ts` encapsulates the bounding-rect check so
per-page specs stay readable.

Per-page specs assert: navigation present, primary CTA present and above fold,
page-specific hero elements present. Selectors use aria roles and names — they
survive CSS refactors and fail only when elements are structurally removed or
pushed off-screen.

## Consequences

- `apps/web-e2e/playwright.config.ts` — replace single Chromium project with
  `mobile`, `tablet`, `desktop` projects
- `apps/web-e2e/src/above-fold.ts` — shared `assertAboveFold` helper
- Per-page spec files in `apps/web-e2e/src/` — one spec per route family,
  added incrementally as pages are built
- Zero new npm dependencies
- CI wire-up: Phase 2 E2E job (described in CLAUDE.md, not yet implemented)
  runs specs against Vercel preview URL post-build; `playwright test
  --project=mobile --project=tablet --project=desktop`
- Does not catch: color regressions, overlapping elements, z-index stacking,
  font rendering differences — these are accepted false-negative categories
  at this stage of development
- Spec maintenance trigger: route renamed, element role/name changed, or
  above-fold layout intentionally shifted
