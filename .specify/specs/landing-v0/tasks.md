# Tasks: Static landing page v0

Plan: `.specify/specs/landing-v0/plan.md`. Each behaviour follows RED (write the smallest
failing test, run it, see it fail, record the failure) → GREEN (minimal code, run, see it
pass) → REFACTOR (clean, run, still passes) → commit. Run `pnpm exec nx run-many -t test`
at every step.

Delivery: one branch, one PR ("Closes #91").

## Slice A — UI tests run and guard the real palette (packages/ui)

- [ ] T001 RED: `pnpm exec nx show project ui --json` lists no `test` target; record it.
- [ ] T002 GREEN: add `packages/ui/vitest.config.ts`; `contrast.test.ts` and `button.test.tsx` run and pass.
- [ ] T003 RED: `contrast.test.ts` adds pairs text/surface, muted/bg, muted/surface, white/blue, text-on-dark/surface-dark using token names that do not exist yet. Fails: names missing on `tokens.color`.
- [ ] T004 GREEN: rewrite `tokens.ts` to the design-system light palette in OKLCH (bg, surface, surfaceDark, navy, blue, text, textMuted, textOnDark, border). Expected: muted/bg and muted/surface body-text assertions fail; resolve per plan D4 (assert 3:1 for muted, large-text use only) unless Q1 says darken.
- [ ] T005 RED: `tokens-parity.test.ts` reads `tokens.css` and compares each `--ems-color-*` value with `tokens.ts`. Fails: file missing.
- [ ] T006 GREEN: add `packages/ui/src/tokens/tokens.css` (`--ems-color-*`, `--ems-radius-*`, `--ems-font-*`). `pnpm run lint:css` passes.

## Slice B — the page is Evan's (apps/web)

- [ ] T007 RED: `apps/web/src/app/page.test.tsx` "renders exactly one h1 reading Evan Leed" using `renderToStaticMarkup` + `DOMParser`. Fails first on JSX transform (record), then on content.
- [ ] T008 GREEN: `apps/web/vitest.config.ts` esbuild `jsx: 'automatic'`; `page.tsx` renders `<h1>Evan Leed</h1>`.
- [ ] T009 RED: page test "does not contain Meditation School". Observed state recorded (may pass immediately after T008; kept as a guard).
- [ ] T010 RED: `layout-metadata.test.tsx` "title is Evan Leed | Trauma-Informed IPF Facilitator and description is non-empty". If importing `layout.tsx` fails under jsdom, record it and move this assertion to T026 per plan D3.
- [ ] T011 GREEN: update `metadata` in `layout.tsx` from `landing-content.ts` (create the module with brand, title, description).

## Slice C — sections, one at a time

Each section: RED test in `apps/web/src/app/landing/<section>.test.tsx` asserting its
heading and copy from `landing-content.ts`; GREEN component; page test asserts it is
composed.

- [ ] T012 RED/GREEN `Hero`: tagline text; link text "Book a free 30-minute consultation"; `href` `https://calendly.com/evan-leed`.
- [ ] T013 RED/GREEN `SiteHeader`: brand text; consultation link to the same URL; asserts no other `a[href]` (no dead links).
- [ ] T014 RED/GREEN `Approach`: both intro paragraphs and the core claim ("Healing attachment patterns isn't about fixing yourself…").
- [ ] T015 RED/GREEN `Credentials`: six list items from the content brief; credential naming Dr. Daniel P. Brown and George Haas present.
- [ ] T016 RED/GREEN `Testimonials`: three `blockquote`s attributed T.H., A.N., Melissa Hower.
- [ ] T017 RED/GREEN `ScopeNote`: disclaimer text exact.
- [ ] T018 RED/GREEN `SiteFooter`: Instagram `http://instagram.com/evanleed` and X `https://x.com/rainbowbodyhug` links with accessible names.
- [ ] T019 RED: page test "no currency amount" (`/\$\s?\d/` absent). Expected to pass on arrival; kept as a guard.
- [ ] T020 RED: page test landmarks — exactly one each of `header`, `main`, `footer`; every `section` has a heading.
- [ ] T021 GREEN: `page.tsx` composes sections top-down with landmarks.

## Slice D — styling

- [ ] T022 Add `apps/web/src/app/globals.css` (only `var(--ems-*)`); import `tokens.css` and `globals.css` in `layout.tsx`. `lint:css` passes; `build` passes (verifies the cross-package CSS import resolves).
- [ ] T023 Signal/Whisper: `Testimonials` is the only dark section; hero gradient panel from `hero-split.html` (decorative, `aria-hidden`).
- [ ] T024 Focus: `:focus-visible` outline on links using `--ems-color-blue`; responsive breakpoints at 640 px and 1024 px.

## Slice E — pipeline proof

- [ ] T025 RED: update `apps/web-e2e/src/smoke.spec.ts` to expect title `/Evan Leed \| Trauma-Informed IPF Facilitator/`, heading "Evan Leed", and the CTA `href`. Run against current production URL with bypass header: fails (old page). Record.
- [ ] T026 GREEN: passes against the PR preview in `2-e2e.yml`.
- [ ] T027 Manual verification: preview at 375 px and 1440 px, keyboard tab-through, screenshots in the PR body.
- [ ] T028 `pnpm run typecheck`, `lint`, `lint:css`, `test`, `build` green; PR "Closes #91"; after merge, confirm production shows the new page and comment the screenshot on #91.
