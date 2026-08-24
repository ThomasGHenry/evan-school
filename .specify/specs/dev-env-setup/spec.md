# Spec: Dev Environment Setup

**Feature:** `dev-env-setup`
**Phase:** 1 (first shippable slice)
**Status:** clarified

---

## Goal

A developer cloning `evan-school` for the first time can run the following sequence
and have all commands succeed:

```
fnm use 22
pnpm install
pnpm run db:generate
pnpm run typecheck
pnpm run build
```

CI (`1-commit.yml`) also passes on push to main.

---

## Success Criteria

1. `pnpm install` completes without error and produces a valid, committed lockfile
2. `pnpm run db:generate` generates Prisma client types without a live database
3. `pnpm run typecheck` exits 0 across all workspace packages and apps
4. `pnpm run build` exits 0 (Next.js build succeeds)
5. CI `prisma-migrate-check` job passes (generate + migrate deploy with Postgres service)
6. CI `typecheck`, `lint`, `build` jobs pass

---

## Out of Scope

- Provisioning real Clerk keys or a Neon database instance
- Running the dev server (`pnpm run dev`) with working auth flows
- E2E tests (those require a deployed Vercel preview URL)

---

## Clarifications Resolved

**Q: Does `pnpm run build` require real Clerk env vars?**
A: `NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY` is a build-time var for the browser bundle.
Clerk's `ClerkProvider` logs a warning when undefined but does not throw during
static rendering. Next.js build succeeds. A `.env.local.example` documents what
the developer must supply for a working dev server session.

**Q: Does `prisma generate` need a live DATABASE_URL?**
A: No. Prisma `generate` reads the schema and writes TypeScript types; it does not
open a database connection. A dummy or empty value is sufficient.

**Q: Does the schema require `url` in the datasource block?**
A: In Prisma 7, `prisma.config.ts` provides `datasource.url` via `env('DATABASE_URL')`,
overriding whatever the schema declares. The schema datasource block without `url`
is valid when the config file supplies it.

**Q: Will `prisma migrate deploy` fail with no migration files?**
A: Prisma outputs "No migration found" and exits 0 when the migrations directory
is absent or empty. The CI job passes.
