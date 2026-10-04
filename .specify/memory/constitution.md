# Project Constitution

---

## Project Identity

| Field | Value |
|---|---|
| **Repo name** | `evan-school` |
| **Owner** | `ThomasGHenry` |
| **Description** | Evan's Meditation School — live meditation courses, mailing list, and student dashboard |
| **Visibility** | public |
| **Instantiated from** | `ThomasGHenry/tgh-template` |
| **Instantiation date** | 2026-08-23 |

---

## Tech Stack (Layer 1: NextJS-Vercel-Prisma Overlay)

| Concern | Choice | Version |
|---|---|---|
| Monorepo tooling | NX | 22 |
| Frontend framework | Next.js, App Router | 15 |
| ORM | Prisma | 7 |
| Database | Neon Postgres (cloud) | postgres 17 |
| Unit tests | Vitest | 4 |
| E2E tests | Playwright | chromium only in CI |
| UI components | shadcn/ui | via `npx shadcn@latest add` |
| Env validation | Zod (`packages/config`) | latest |
| Deployment | Vercel | GitHub App integration |
| IaC | OpenTofu | >= 1.6 |
| Node | 22 (`.nvmrc`) | LTS |
| Package manager | pnpm workspaces (`pnpm-workspace.yaml`) | 10.34.5 (`packageManager`); lockfile committed; 7-day `minimumReleaseAge` |

---

## Governance Philosophy

The governance layer is the primary value of this template, not the framework scaffold.

### ADRs
- Every architectural decision gets an ADR in `docs/adr/`
- Numbering: 4-digit, sequential (`0001-kebab-slug.md`)
- All ADRs have YAML frontmatter: `status`, `date`, `tags`
- `accepted` + `tooling` ADRs require an `implementation:` field
- Bidirectional supersession: `supersedes`/`superseded-by` links are validated by CI
- Template ships ADRs 0001–0005 as format examples; instantiators delete and replace all of them
- `docs/adr/0000-template.md` is the format specification; never validated, never deleted

### Conventional Commits
- Enforced by commitlint at `commit-msg` stage AND by `validate-commits.sh` in CI
- Header maximum: 72 characters
- Subject must not start with uppercase after the type+scope prefix
- Allowed types: `feat`, `fix`, `chore`, `docs`, `test`, `refactor`, `perf`, `ci`, `build`, `revert`
- Merge commits are skipped by validation

### CI Gate Architecture
- **Phase 0** (governance, all parallel): `gitleaks`, `actionlint`, `validate-adrs`, `validate-commits`, `shellcheck`, `supply-chain-policy`, `pnpm-audit`, `prisma-migrate-check`
- **Phase 1** (compute, all parallel, blocked by Phase 0): `typecheck`, `lint`, `test`, `build`
- **Aggregate**: `commit-validation` job reads `$NEEDS_JSON`, fails if any required job did not succeed
- `commit-validation` is the **sole required GitHub status check** in branch protection
- Auto-failure issue creation via `auto-triage.yml` on `commit-validation` failure

### Deploy Chain
```
push to main
  → Vercel GitHub App builds preview (automatic)
  → 1-commit.yml (Phase 0 → Phase 1 → commit-validation)
  → 2-e2e.yml (Playwright against Vercel preview URL)
  → 3-promote.yml (prisma migrate deploy + vercel promote)
```
Each stage triggers the next via `workflow_run: types: [completed]` + conclusion check.

### IaC (GitHub Settings)
- `infra/github/` manages: branch protection, labels, environments, merge strategy
- Tofu plan on PR (posts comment), apply on main push
- Remote state: GCS or Cloudflare R2 (never local)
- State bucket created manually before `tofu init` (bootstrap exception)
- Application infrastructure (`infra/app/`) is instance-specific — not in this template

---

## Module Boundaries

### Package Taxonomy

| Package / App | NX Tag | Rule |
|---|---|---|
| `apps/web` | `scope:web` | may import `scope:web` and `scope:shared` |
| `apps/web-e2e` | `scope:web` | test runner only, no production imports |
| `packages/ui` | `scope:shared` | React components, shadcn/ui; no Prisma |
| `packages/config` | `scope:shared` | env validation via Zod; no React, no Prisma |
| `packages/db` | `scope:shared` | Prisma client singleton; single import point |
| `packages/domain` | `scope:domain` | pure TypeScript; **no React**, **no `@prisma/client`** direct import |

### Boundary Rules
- `scope:domain` → may only depend on `scope:shared`
- `scope:web` → may only depend on `scope:web` or `scope:shared`
- Domain imports DB types, not the client: `import type { User } from '@<ns>/db'`, not `import { PrismaClient }`
- A `no-restricted-imports` ESLint rule explicitly bans `@prisma/client` in `packages/domain`
- Boundaries are enforced by `@nx/enforce-module-boundaries` in `eslint.config.mjs` and activated by `project.json` tags on every project

### Package Naming Convention
- Template namespace: `@template/*`
- Instantiators rename to `@<project-slug>/*` (e.g. `@mde/*`) and update all imports

---

## Testing Strategy

| Layer | Tool | Location | Notes |
|---|---|---|---|
| Shell scripts | BATS | `scripts/ci/*.bats` | Every `.sh` must have a sibling `.bats`; stubs do not count |
| BATS coverage | `validate-bats-coverage.sh` | Phase 0 CI job | Enforces the sibling rule in CI |
| Unit (domain logic) | Vitest | `packages/domain/src/**/*.test.ts` | `environment: 'node'` |
| Unit (env config) | Vitest | `packages/config/src/**/*.test.ts` | `parseEnv()` must have coverage |
| Unit (UI components) | Vitest (optional) | `packages/ui/src/**/*.test.tsx` | Decision: record in DECISIONS.md |
| Unit (web app) | Vitest | `apps/web/src/**/*.test.tsx` | `environment: 'jsdom'` |
| E2E | Playwright | `apps/web-e2e/src/**/*.spec.ts` | Chromium only in CI; against Vercel preview URL |
| Schema validity | `prisma-migrate-check` | Phase 0 CI job | Postgres 17 Alpine service container |

---

## Non-Negotiables (16)

Do not revisit during implementation. These are closed decisions.

1. **Template-as-snapshot** — no generator, no version sync, no setup.sh (for now)
2. **`commit-validation` is the sole required GitHub status check** — one entry in branch protection
3. **Phase 0 gates Phase 1** — governance jobs must all pass before typecheck/lint/test/build run
4. **Squash-only merges** — configured in both Tofu IaC and `nx.json` settings
5. **Linear history required** — no merge commits on main
6. **0 required human reviewers** — automation is the gate; human review is optional
7. **Auto-merge enabled** — PRs merge automatically when all checks pass
8. **OpenTofu manages GitHub settings** — not the GitHub UI
9. **GCS or Cloudflare R2 remote state** — never local state for Tofu
10. **Conventional commits enforced** — commitlint at commit-msg stage + CI validation
11. **72-character commit header maximum** — enforced by commitlint rule
12. **ADRs use 4-digit numbering** — `0001-kebab-slug.md`, not date-based
13. **Accepted tooling ADRs require `implementation:` field** — links to where it lives
14. **`validate-aggregate.sh` reads `$NEEDS_JSON`** — same pattern as buen-vecino
15. **No automated dependency-update bots; updates are deliberate with a >= 7-day release cooldown** — see ADR 0124
16. **Major dependency upgrades are human-initiated and get the `needs-adr-review` label** — never auto-merged

---

## Domain Model — Evan's Meditation School

**Repo:** `evan-school` | **Instantiated:** 2026-08-23

### Entities

| Entity | Table | Key fields |
|---|---|---|
| `User` | `users` | `id`, `email`, `role` (enum), `mailchimpId` |
| `Course` | `courses` | `id`, `slug`, `title`, `zoomLink`, `recordingUrl`, `status` (enum) |
| `CourseContent` | `course_content` | `courseId`, `section` (enum), `contentUrl`, `sortOrder` |
| `Enrollment` | `enrollments` | `userId`, `courseId`, `paidAt`, `paymentRef`, `accessGranted` |
| `Post` | `posts` | `slug`, `title`, `body`, `seoMeta`, `publishedAt` |
| `Resource` | `resources` | `slug`, `title`, `contentType`, `contentUrl`, `publishedAt` |

### Access Tiers (UserRole enum)

| Tier | Role | Routes |
|---|---|---|
| 0 | Anonymous | `/`, `/blog/**`, `/courses`, `/courses/[slug]`, `/checkout`, `/login`, `/signup` |
| 1 | SUBSCRIBER | above + `/resources/**`, `/account` |
| 2 | STUDENT | above + `/dashboard`, `/courses/[slug]/content` (scoped to enrolled courses) |
| 3 | ADMIN | everything + `/admin/**` |

### Key Invariants

- `Enrollment.accessGranted = true` is required for a STUDENT to access a course's content. Middleware gates authentication; route handlers gate per-course authorization via the enrollments table.
- Course content visibility follows `ContentSection` ordering: INTRO → SETTING_THE_STAGE → ZOOM_LINK → RECORDING_LINK → MEDITATION_RESOURCES.
- A student enrolled in Course A has no access to Course B (scoped enrollments, not blanket role).
- `User.mailchimpId` mirrors the MailChimp subscriber ID; kept in sync on enrollment and signup.
- Payments are single-transaction only (no subscriptions). `Enrollment.paymentRef` stores the PayPal IPN transaction ID at MVP.

### Auth

Clerk (`@clerk/nextjs`) manages session tokens and UI flows. `User.role` in our DB drives tier-based authorization. See ADR 0100.
