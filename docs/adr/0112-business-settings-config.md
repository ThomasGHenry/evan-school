---
status: accepted
date: 2026-08-28
tags: [architecture]
implementation: packages/domain/src/business-settings.ts
---

# 0112. Central BusinessSettings configuration

## Context

Business configuration values — session price, consultation duration, Calendly
URL, contact email, scope statement — appear on multiple pages (landing page,
`/the-work`, `/about`, `/contact`, course pages). If these values are duplicated
in page copy, a pricing change or Calendly URL update requires hunting through
every component that mentions it. A missed instance produces a live inconsistency
visible to visitors and crawlers.

seo.md §11 specifies a `BusinessSettings` object as the single source of truth
for all such values, explicitly prohibiting duplication in copy.

## Decision

`packages/domain/src/business-settings.ts` exports a typed `BusinessSettings`
object. All page components and JSON-LD schemas import from this module. Values
are never hardcoded in JSX or schema files.

```ts
export type RetreatPricing = {
  sustainingPrice: number
  standardPrice: number
  reducedPrice: number
}

export type BusinessSettings = {
  sessionPrice: number
  sessionDuration: string
  slidingScalePrice: number
  consultationDuration: string
  retreatPricing: RetreatPricing
  calendlyUrl: string
  contactEmail: string
  scopeStatement: string
  acceptsNewClients: boolean
}

export const businessSettings: BusinessSettings = {
  sessionPrice: 200,
  sessionDuration: '50 minutes',
  slidingScalePrice: 150,
  consultationDuration: '30 minutes',
  retreatPricing: {
    sustainingPrice: 249.99,
    standardPrice: 199.99,
    reducedPrice: 149.99,
  },
  calendlyUrl: 'https://calendly.com/evanleed/consultation',
  contactEmail: 'evan@evanleed.com',
  scopeStatement:
    'I work with adults seeking emotional regulation and secure attachment through the Internal Family Systems and Ideal Parent Figure Protocol frameworks. I do not provide therapy, diagnosis, or crisis intervention.',
  acceptsNewClients: true,
}
```

`retreatPricing` values confirmed from live evanleed.com Squarespace checkout
(August 2026). All other values are placeholders pending owner confirmation
(seo.md §102). `calendlyUrl`, `sessionPrice`, `slidingScalePrice`, and
`scopeStatement` must be verified with Evan before the site goes live.

## Consequences

- `packages/domain/src/business-settings.ts` created with typed interface and
  placeholder defaults
- Landing page CTA uses `businessSettings.calendlyUrl` — not a hardcoded URL
- `/the-work` page uses `businessSettings.sessionPrice`,
  `businessSettings.sessionDuration`, `businessSettings.slidingScalePrice`
- `/contact` page uses `businessSettings.contactEmail`
- `Service` JSON-LD on `/the-work` uses `businessSettings.sessionPrice`
- `Person` JSON-LD on `/` and `/about` uses `businessSettings.scopeStatement`
- GitHub issue #48 tracks implementation and owner confirmation of values
