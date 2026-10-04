---
status: proposed
date: 2026-10-04
tags: [architecture, auth, data-model]
supersedes: 0122-resources-index-visibility.md
---

# 0125. Payload as sole data model owner, with tiered content access and entitlements

## Context

ADR 0108 made Payload CMS v3 the authentication and admin layer. The repository
still carries the template's Prisma overlay (ADR 0003): `packages/db`, a Prisma
schema with one migration, and the `prisma-migrate-check` CI job. Two schema and
migration owners on one Neon database would mean two definitions of a user,
recreating the identity-sync problem ADR 0108 removed when it dropped Clerk.

Content-access requirements were decided with the founder on 2026-10-04
(issue #79, comments on #79, #81, #2):

- Three access tiers:
  - **public**: free to everyone and fully indexable (SEO/AEO/GEO);
  - **subscriber**: free, but requires a signed-in account AND an active
    mailing-list subscription;
  - **paid**: granted to the members of a specific class cohort, or to the
    buyer of a standalone product.
- Paid access never expires, and repeat students keep every cohort's materials.
- Unsubscribing from the mailing list removes subscriber-tier access, including
  for paid students. Their paid access is unaffected.
- Standalone products are in scope at launch. One placeholder product is live
  and visible at launch, to test the purchase flow and gather feedback.
- The resources index is a public catalogue of every tier. Gating happens per
  item (#13), replacing ADR 0122's binary `isPublic` model.

These capabilities were verified against Payload 3.88.0, as used in
`Premium-Marketing-Platform-Reference-Impl`:

- Access functions may be async and return `boolean | Where`. They receive
  `req: PayloadRequest`, which carries `payload` for lookups across related
  collections: `payload/dist/config/types.d.ts` L231–252 and
  https://payloadcms.com/docs/access-control/overview. A `Where`-returning read
  is shown in Reference Impl `apps/web/src/collections/Posts.ts` L10–14.
- The database adapter exposes `beginTransaction`, `commitTransaction` and
  `rollbackTransaction`. `PayloadRequest.transactionID` scopes Local API calls,
  which accept `req`: `payload/dist/database/types.d.ts` L12–112,
  `payload/dist/types/index.d.ts` L63, and
  `payload/dist/collections/operations/local/create.d.ts` L75.
- Collection auth with a role field: Reference Impl
  `apps/web/src/collections/Users.ts` (`auth: true`, `role` select).
- The Postgres adapter exposes its Drizzle instance for raw queries:
  `@payloadcms/drizzle/dist/types.d.ts` L284 (`drizzle`).

## Decision

Payload v3 on Neon Postgres (`@payloadcms/db-postgres`) is the sole owner of
the application schema and its migrations. Prisma is removed.

Collections:

| Collection | Purpose |
|---|---|
| Users | Payload auth; `role` (admin, member); mailing-list subscription status synced from MailChimp |
| Courses | Course marketing records |
| Cohorts | A dated run of a course; the unit paid course access is granted on |
| Products | Standalone purchasable items |
| Entitlements | One row per grant: user × (cohort or product). Permanent and additive; never deleted on expiry |
| CourseContent | Sections belonging to a cohort (intro, setting the stage, Zoom link, recording, meditations) |
| Guides | Public articles |
| Resources | Catalogue items at any tier |
| Events | Event listings |

Every gated item carries an `access` tier (`public`, `subscriber` or `paid`).
Paid items also reference the cohort or product that unlocks them. One access
rule serves all gated content:

- `public` → readable by anyone.
- `subscriber` → readable when the user is signed in and their subscription
  status is active.
- `paid` → readable when an Entitlement exists for the user and the item's
  cohort or product.
- `admin` role → readable regardless of tier.

The Stripe webhook verifies the event signature. Inside one Payload transaction
it then creates or links the user and creates the Entitlement. It is idempotent
on the Stripe event id. Public catalogue and marketing pages list items of every
tier with a badge and a teaser. The item route renders the content, a sign-up
prompt or a purchase prompt.

This ADR supersedes ADR 0122. ADR 0003 (template, Prisma) is not edited in this
instance; its supersession is carried upstream in ThomasGHenry/tgh-template.

## Consequences

Executed under #3 (Payload install), not by this ADR:

- Delete `packages/db` and its Prisma schema and migration.
- Remove the `@prisma/*` and `prisma` dependencies.
- Remove the `prisma-migrate-check` Phase 0 job, both from `1-commit.yml` and
  from `commit-validation`'s `needs:`.
- Change `3-promote.yml` to run Payload migrations instead of
  `prisma migrate deploy`.

Other effects:

- Domain types come from Payload's generated `payload-types.ts`. The
  constitution's Prisma-specific boundary rules (`packages/db`, the
  `@prisma/client` import ban) are replaced under #82.
- Removing Prisma also removes the `deepmerge-ts` and `mysql2` audit-ignore
  entries that ADR 0124 attributes to Prisma. Revisit the ignore list then.
- Checkout (#81) provisions Entitlements for both cohorts and products, and the
  PRD's "single-transaction purchases only" constraint still holds.
- Subscriber access depends on MailChimp sync (#2). A sync outage could leave
  an unsubscribed user with access, or deny a subscribed one, until the next
  sync.
- The admin panel manages Cohorts, Products and Entitlements directly. That
  covers comps and refunds (§6.9) without custom admin pages.
- The PRD's access-related sections are updated in the same change as this ADR.

## Hypothesis

One access rule over Entitlements will serve course content, resources and
products without per-collection special cases. Confirmed if #1, #13 and #81 ship
with each collection's read access built from the same shared access functions,
and their tests cover the anonymous, subscriber, unsubscribed, entitled and
not-entitled cases.
