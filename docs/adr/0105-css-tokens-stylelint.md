---
status: accepted
date: 2026-08-25
tags: [tooling, css, design-system]
implementation: .stylelintrc.json
---

# 0105. CSS design tokens with stylelint enforcement

## Context

Evan School has a fully specified Figma design system with a named token set
(`--ems-color-*`, `--ems-spacing-*`, `--ems-radius-*`, `--ems-font-*`). Without
enforcement, component CSS files accumulate hardcoded hex values and raw sizes.
When the design evolves, changes must then be grep-and-replaced across many files
rather than updated in a single token definition.

The project is a bespoke editorial brand — not a generic product UI — so
utility-first frameworks (Tailwind) fight the token system rather than complement
it. The design values do not map to Tailwind's default scale.

## Decision

We will use CSS custom properties as the sole design token mechanism, enforced
by stylelint.

- All design values (colors, spacing, radii, typography) are defined once in
  `packages/ui/src/tokens.css` as CSS custom properties following the
  `--ems-<category>-<name>` naming convention.
- Component CSS modules (`*.module.css`) consume tokens exclusively via
  `var(--ems-*)`. Raw hex, rgb, hsl, or hardcoded pixel values for color are
  forbidden in component files.
- stylelint `declaration-property-value-disallowed-list` enforces the ban on
  raw color values in all CSS files except `tokens.css` and files under
  `tokens/`.
- `custom-property-pattern` enforces the `--ems-*` naming convention.
- The `lint:css` NX target runs stylelint across `packages/ui/src/**/*.css` and
  `apps/web/src/**/*.css`.

shadcn/ui components are permitted in the student portal only (auth, enrollment
flows, modals) and must override their internal variables to consume `--ems-*`
tokens at the boundary.

## Consequences

Easier:
- Design changes propagate everywhere by editing `tokens.css`.
- CI catches drift between design intent and component implementation.
- No framework opinion conflicts with the editorial token set.

Harder:
- Component authors must look up token names rather than writing hex inline.
- `tokens.css` must be kept current with Figma as the design evolves; no
  automated Figma-to-code sync is in place yet (deferred until design stabilises).

Risks:
- Token sprawl if the naming convention is not followed consistently — mitigated
  by the `custom-property-pattern` stylelint rule.
