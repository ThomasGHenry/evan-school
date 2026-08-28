---
status: accepted
date: 2026-08-28
tags: [architecture, content]
implementation: packages/domain/src/claims.ts
---

# 0113. Claims registry

## Context

seosop.md Domain F (mandatory controls) requires that all claims about Evan's
credentials, training, practice scope, and efficacy be accurate, sourced, and
reviewed before publication. The site makes claims that are verifiable,
professionally sensitive, and — in the context of the GEO strategy — the
primary trust signals that distinguish Evan from fraudulent incumbents. An
unsourced or inaccurate claim undermines the authority the GEO strategy is
built on.

Categories of claims that require registration:
- Biographical (training lineage, length of practice, certifications)
- Scope (what Evan does and does not do — critical for safety and legal clarity)
- Efficacy (outcomes, what clients experience)
- Service (pricing, session structure, availability)

Claims that appear in copy, JSON-LD schemas, or `BusinessSettings` must be
traceable to a source before the site goes live.

## Decision

`packages/domain/src/claims.ts` exports a typed `Claim[]` registry. Every
claim that appears on the public site must have a corresponding entry. No
claim may be published without a source citation and a `verifiedAt` timestamp.

```ts
export type Claim = {
  id: string
  category: 'biographical' | 'scope' | 'efficacy' | 'service'
  approvedWording: string
  prohibitedWording?: string
  source: string
  verifiedBy: string
  verifiedAt: string        // ISO date
  reviewAfter: string       // ISO date — when to re-verify
}
```

The registry is not rendered to users. It is a compile-time reference document
for developers and a pre-launch QA gate. Before launch, every claim used in copy
must have a matching registry entry.

Placeholder entries ship with the codebase. Evan must review and confirm all
entries before DNS cutover — this is a launch gate, not a post-launch task.

## Consequences

- `packages/domain/src/claims.ts` created with typed `Claim` interface and
  placeholder entries for scope statement, training lineage, session pricing,
  and practice area claims
- Pre-launch QA checklist includes: every claim in copy has a registry entry,
  all `verifiedAt` dates are current, no `prohibitedWording` appears in any
  published page
- `BusinessSettings.scopeStatement` must match an approved claim entry
- Evan reviews and signs off on all claims before DNS cutover
- GitHub issue #48 (BusinessSettings) depends on this — scope statement in
  `BusinessSettings` must come from an approved claim entry
