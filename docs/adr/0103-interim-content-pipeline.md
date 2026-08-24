---
status: accepted
date: 2026-08-24
tags: [architecture, content]
implementation: packages/domain/src/content.ts
---

# 0103. Interim Content Pipeline: gray-matter via Typed Domain Interface

## Context

PRD §8 specifies file-based or hardcoded content at MVP, with a Prisma-backed
custom admin UI in Phase 3. A mechanism is needed to populate page copy (headlines,
body text, CTA labels, section copy) without hardcoding strings in components or
committing to a third-party CMS that conflicts with the Phase 3 direction.

The key constraint: **the content source changes in Phase 3, not the components.**
Components must never know whether content comes from a file or the database. The
abstraction seam must be at the domain layer, not the component layer.

Options evaluated:

**`@next/mdx` / `next-mdx-remote`** — MDX files become or produce React trees.
Inverts control: the file drives the layout. Ruled out — we need content to populate
components, not components embedded in content.

**Velite** — build-time transform of md/mdx to typed JSON; components import
generated data. Right pattern, but adds a build-time artifact layer (`/.velite/`)
and NX pipeline integration for a layer explicitly scheduled for replacement. Overkill.

**Keystatic** — git-based CMS with local admin UI. Would compete with the Phase 3
Prisma admin UI rather than bridging to it. Gets thrown away at the same time as any
file-based approach, but with substantially higher setup cost.

**Contentlayer** — archived 2024. Ruled out.

**`gray-matter` + `fs.readFileSync`** — parse YAML frontmatter from `.md` files
in a server-only domain utility. One new dependency. The Zod schema that validates
frontmatter shape doubles as the contract for the future Prisma query return type.

## Decision

`gray-matter` + `fs.readFileSync` in `packages/domain/src/content.ts`, accessed
exclusively through a typed `getPageContent(slug: string): PageContent` interface.

The architecture enforces the seam via three rules:

1. **Components import only `PageContent` (the type).** They never import
   `gray-matter`, `fs`, or anything from `content/`.
2. **`getPageContent` is the single egress point.** All file reads go through it.
3. **The Zod schema is the migration contract.** The same `PageContentSchema`
   that validates frontmatter defines the shape the Prisma query must return.

```
content/
  landing.md         ← YAML frontmatter sections (hero, courses, about, cta...)
  courses.md
  blog/[slug].md

packages/domain/src/
  content.ts         ← getPageContent(slug), readMarkdownFile(), PageContentSchema
  content.types.ts   ← export type PageContent = z.infer<typeof PageContentSchema>

apps/web/src/app/
  page.tsx           ← const content = await getPageContent('landing')
  components/
    HeroSection.tsx  ← receives content.hero; no knowledge of source
    CourseCard.tsx   ← receives content.courses[n]; no knowledge of source
```

**Phase 3 migration:** Replace `readMarkdownFile(slug)` inside `getPageContent`
with `prisma.pageContent.findUnique({ where: { slug } })`. Component signatures
do not change. The Zod schema documents the required DB columns before migration.

## Consequences

- `pnpm add gray-matter` in `packages/domain` (`zod` already present via
  `@evan-school/config`)
- `content/` directory at monorepo root holds `.md` files with structured
  frontmatter — not Markdown prose, structured key-value sections
- `packages/domain/src/content.ts` — `getPageContent`, `readMarkdownFile`,
  `PageContentSchema` (Zod)
- `packages/domain/src/content.types.ts` — exported `PageContent` type
- `apps/web` imports `@evan-school/domain` — already a workspace dependency
- Server-components-only; `fs` is not available client-side. `getPageContent`
  must only be called from Server Components or Server Actions
- Throwaway layer by design: when Phase 3 ships, one function changes. This is
  the correct tradeoff given the PRD's explicit Phase 3 direction
- Content files are version-controlled — content changes go through PR review
  until Phase 3 admin UI exists
