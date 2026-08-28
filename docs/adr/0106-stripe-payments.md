---
status: accepted
date: 2026-08-25
tags: [architecture, tooling, payments]
implementation: apps/web/src/app/api/webhooks/stripe/route.ts
---

# 0106. Stripe for payment processing

## Context

PRD §11 Q6 noted PayPal as the MVP bridge and Stripe as the target, with the
migration trigger left undefined. The current Squarespace/PayPal workflow is
entirely manual: Evan receives a PayPal notification, then manually sends the
student a password. This does not scale and cannot support automated enrollment
provisioning.

Building the PayPal integration first and migrating later doubles the webhook
implementation work and delays self-serve enrollment — the primary Phase 1
outcome.

## Decision

Stripe from Phase 1. PayPal is not implemented.

**Scope:** Stripe processes **course enrollment only**. The IPF Weekend Retreat
currently uses Squarespace commerce (external checkout) — retreat payments are
not processed by this integration at MVP. Migrating retreat payments to Stripe
is a post-MVP decision requiring a separate ADR.

Enrollment flow:
1. Student submits checkout → Stripe Payment Intent created
2. `payment_intent.succeeded` webhook fires → API route provisions enrollment row
3. Payload CMS account created or linked → course access granted immediately
4. Confirmation email sent via MailChimp transactional trigger

No subscription billing. Single-transaction purchases only (per PRD §12).

## Consequences

- `stripe` SDK added to `apps/web` dependencies
- `STRIPE_SECRET_KEY`, `STRIPE_WEBHOOK_SECRET`, `NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY`
  added to env schema in `packages/config/src/index.ts`
- Webhook endpoint at `apps/web/src/app/api/webhooks/stripe/route.ts` handles
  `payment_intent.succeeded` and provisions `Enrollment` row
- Existing PayPal students (from Squarespace era) are manually migrated on launch
  — backfill script seeds their enrollment records
- Stripe fee (~2.9% + 30¢ per transaction) is the cost of automation
- PRD §11 Q6 (PayPal→Stripe migration timing) is closed — Stripe is Phase 1
- Retreat checkout remains on Squarespace at MVP; no Stripe integration needed
  for retreat purchases until explicitly scoped
