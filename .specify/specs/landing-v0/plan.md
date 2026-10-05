# Plan: Static landing page v0

Spec: `.specify/specs/landing-v0/spec.md`. Issue: #91 (part of #5).

## Verified facts this plan depends on

| Fact | Source |
|---|---|
| `page.tsx` renders only `<h1>Evan&apos;s Meditation School</h1>` | `apps/web/src/app/page.tsx` |
| Layout metadata is `title: "Evan's Meditation School"`, `description: 'Live meditation courses with Evan.'` | `apps/web/src/app/layout.tsx:4-7` |
| E2E smoke asserts the old title and heading | `apps/web-e2e/src/smoke.spec.ts:5,10` |
| E2E runs against the preview URL with the Vercel bypass header | `.github/workflows/2-e2e.yml:36`, `apps/web-e2e/playwright.config.ts:15-18` |
| No Tailwind, PostCSS or global CSS in `apps/web`; `Button` uses Tailwind class names that therefore do nothing | `apps/web` file list; `packages/ui/package.json` (no tailwindcss); `packages/ui/src/components/button.tsx:5-12` |
| Stylelint already governs CSS: literal colours banned outside `**/tokens.css` / `**/tokens/**/*.css`; custom properties must match `^ems-…`; properties alphabetical | `.stylelintrc.json` |
| `lint:css` targets exist for `apps/web/src/**/*.css` and `packages/ui/src/**/*.css` | `apps/web/project.json`, `packages/ui/project.json` |
| `tokens.ts` holds a dark OKLCH palette (background L 0.14) that matches neither the design system nor anything rendered | `packages/ui/src/tokens/tokens.ts` |
| `packages/ui` has no `vitest.config.ts`, so `@nx/vite` infers no `test` target and `contrast.test.ts` / `button.test.tsx` never run in CI | `nx.json` plugins; `find . -name vitest.config.*` → apps/web, packages/config, packages/domain only |
| `apps/web` tsconfig uses `"jsx": "preserve"`; Vitest must transform JSX itself | `apps/web/tsconfig.json:4`; `apps/web/vitest.config.ts` |
| `@testing-library/react` is not installed | `pnpm-lock.yaml` (0 matches) |
| Design system tokens: bg `#f0eeea`, surface `#e8e5df`, surface-dark `#111827`, navy `#1e2d5b`, blue `#2563eb`, text `#1a2744`, text-muted `#6b7280`, text-on-dark `#f0eeea`, border `#d1cec8`; radii 8/16/24/999; Georgia serif, system sans | `../evan-school-ds/_tokens.css` |
| DS `--text-muted` `#6b7280` on bg `#f0eeea` is about 4.17:1, below AA for body text (4.5:1); white on blue `#2563eb` is about 5.17:1 | WCAG relative-luminance calculation |

## Decisions

### D1 — Tokens reach the app as CSS custom properties, through the path stylelint already defines

- New `packages/ui/src/tokens/tokens.css`: the design-system values as `--ems-*` custom
  properties on `:root` (the only file allowed literal colours, per `.stylelintrc.json`
  overrides).
- `tokens.ts` is rewritten to the same light palette in OKLCH, so the existing
  `oklchContrastRatio` tests guard the colours actually rendered.
- A parity test in `packages/ui` reads `tokens.css` and fails if any colour differs from
  `tokens.ts`. Justification (constitution: no abstraction without an earned scar): the
  template's `tokens.ts` already drifted from the design system unnoticed; two
  representations without a check will drift again.
- Imported once from `apps/web/src/app/layout.tsx` together with a new
  `apps/web/src/app/globals.css` (layout, typography, sections) that uses only
  `var(--ems-*)`.
- No Tailwind. Rejected: it is not installed, would add dependencies under the 7-day
  cooldown regime (ADR 0124), and stylelint is already configured for plain CSS. The
  unused Tailwind classes in `Button` are noted, not fixed here; v0 renders links, not
  buttons.

### D2 — Static content as a typed module, markup as small named section components

- `apps/web/src/app/landing-content.ts`: one exported constant holding every string and
  URL (brand, tagline, CTA label and href, intro paragraphs, core claim, credentials,
  testimonials with attribution, disclaimer, social links, metadata). Copy is `[LIFT]`
  text from the content brief. This is the seam #5 and #48 later replace with
  BusinessSettings and Payload.
- `apps/web/src/app/landing/*.tsx`: `SiteHeader`, `Hero`, `Approach`, `Credentials`,
  `Testimonials`, `ScopeNote`, `SiteFooter`, each a named function taking its slice of
  content. `page.tsx` composes them top-down.
- Signal/Whisper: Whisper (light, flat) everywhere except `Testimonials`, the single
  Signal section (`surface-dark` background, `text-on-dark`). The hero keeps the
  design system's decorative gradient panel from `hero-split.html`, CSS only, no image.

### D3 — Render tests without a new dependency

- Section tests render with `react-dom/server` `renderToStaticMarkup` and query the
  result through jsdom's `DOMParser` (Vitest already uses `environment: 'jsdom'`).
  No `@testing-library/react`: fewer new packages, consistent with ADR 0124.
- Vitest config gains an esbuild JSX setting (`jsx: 'automatic'`) because the app
  tsconfig preserves JSX.
- Metadata is asserted by importing `metadata` from `layout.tsx`. If importing the layout
  under jsdom fails because of `@clerk/nextjs`, the metadata assertion moves to the E2E
  smoke only; that outcome is recorded in tasks.md.

### D4 — Contrast is enforced on every text/background pair the page uses

Pairs: text/bg, text/surface, muted/bg, muted/surface, white/blue (CTA),
text-on-dark/surface-dark. The DS muted colour fails body-text AA; see open question Q1.
Default if unanswered: keep `#6b7280` only for text at or above 18.66 px bold / 24 px
(3:1 rule) and use `--ems-color-text` for all smaller copy, so no design-system value
changes.

### D5 — Packages UI tests start running

`packages/ui/vitest.config.ts` is added so the contrast and parity tests run in CI
(they currently never run). The existing `button.test.tsx` runs as a side effect.

## Files

| File | Change |
|---|---|
| `packages/ui/vitest.config.ts` | new |
| `packages/ui/src/tokens/tokens.ts` | light DS palette in OKLCH |
| `packages/ui/src/tokens/tokens.css` | new, `--ems-*` custom properties |
| `packages/ui/src/tokens/contrast.test.ts` | pairs from D4 |
| `packages/ui/src/tokens/tokens-parity.test.ts` | new |
| `apps/web/vitest.config.ts` | JSX transform |
| `apps/web/src/app/landing-content.ts` | new |
| `apps/web/src/app/landing/*.tsx` + `*.test.tsx` | new sections and tests |
| `apps/web/src/app/page.tsx`, `page.test.tsx` | compose sections |
| `apps/web/src/app/globals.css` | new |
| `apps/web/src/app/layout.tsx`, `layout-metadata.test.tsx` | metadata, CSS imports |
| `apps/web-e2e/src/smoke.spec.ts` | new title, heading, CTA href |

## Verification beyond tests

- `pnpm run typecheck`, `lint`, `lint:css`, `test`, `build` pass locally and in CI.
- Manual: open the preview URL in a browser at 375 px and 1440 px, tab through every
  link, screenshot both widths into the PR description.

## Open questions

- Q1: The design system's muted grey fails WCAG AA for body text. Keep it for large text
  only (default above), or darken it (changes a design-system value)?
- Q2: Evan's photo or any imagery: none exists in the repo; v0 ships with the CSS
  gradient panel only. Is that acceptable for the first review?
