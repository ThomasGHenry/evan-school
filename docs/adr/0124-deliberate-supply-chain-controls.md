---
status: accepted
date: 2026-10-04
tags: [tooling, ci, dependencies, security]
implementation: scripts/ci/check-supply-chain-policy.sh
---

# 0124. Replace automated dependency updates with deliberate supply-chain controls

## Context

`renovate.json` extends `config:recommended` and `helpers:pinGitHubActionDigests`, and
its minor/patch group sets `"automerge": true`. ADR 0021 (template meta-ADR, status
`proposed`) argues for that automerge to reduce PR toil.

An update bot pulls each newly published release, including transitive ones, into the
repository shortly after publication. That is the window in which a compromised npm
release is live and not yet yanked. Automerge removes the last human checkpoint, so the
risk concentrates there. Owner discussions on 2026-08-23, 2026-08-28 and 2026-09-19
concluded that this trade is not worth the toil it saves for this project.

Facts measured on `main` at `1c9ef82`:

- `package.json` pins `"packageManager": "pnpm@10.11.0"`.
- pnpm documents `minimumReleaseAge` ("Added in: v10.16.0"), `trustPolicy` ("Added in:
  v10.21.0") and `blockExoticSubdeps` ("Added in: v10.26.0") as top-level keys of
  `pnpm-workspace.yaml` (https://pnpm.io/settings, section "Dependency Resolution").
  None of them take effect on 10.11.0.
- tgh-template commit `c60fc00` placed those keys under a `security:` block, a nesting
  the pnpm docs do not describe, while also on pnpm 10.11.0.
- `pnpm audit --audit-level=high` exits 1 with "59 high | 2 critical" (all deps) and
  "20 high | 2 critical" (`--prod`). The criticals are two `next` advisories patched in
  `>=15.5.24`. tgh-template added an audit gate in `3e2f971` and reverted it in
  `19917a5` for the same two advisories. PR #72 (`d3edfd7`) moved `next` to `15.5.24`;
  afterwards `pnpm audit --prod --audit-level=high` reports "1 low | 15 moderate |
  17 high" and no critical.
- Every workflow `uses:` reference is tag-pinned (for example `actions/checkout@v4`).

This ADR deliberately does not use the `supersedes:` frontmatter key. `validate-adrs.sh`
`check_superseded_status` requires the superseded ADR to carry `status: superseded`, and
`CLAUDE.md` marks ADRs 0001-0099 as template meta-ADRs not to be modified in instances.
ADR 0021 is overridden for this instance by this ADR; the formal supersession belongs
upstream in tgh-template.

## Decision

We will not run any automated dependency-update bot (Renovate, or Dependabot version
updates). Dependency currency becomes a deliberate human act backed by these controls:

1. `pnpm-lock.yaml` remains the source of truth for resolved versions.
2. `pnpm-workspace.yaml` sets, as top-level keys, `minimumReleaseAge: 10080` (7 days),
   `trustPolicy: no-downgrade` and `blockExoticSubdeps: true`. `packageManager` moves to
   the newest pnpm 10.x release that is at least 7 days old and no older than v10.26.0,
   the first version that supports all three keys.
3. `shamefully-hoist=true` moves from `.npmrc` to `shamefullyHoist: true` in
   `pnpm-workspace.yaml`, so `.npmrc` holds only auth and registry settings.
4. `pnpm audit --prod --audit-level=high` runs as a blocking Phase 0 job in
   `1-commit.yml`, landed only after `main` audits clean. Dev-dependency findings are
   reported in the same job by a non-blocking step. Advisories with no fix reachable
   under the 7-day cooldown are listed in pnpm's audit ignore configuration, and each
   one is recorded in the Audit Ignore List below with its reason and review date.
   `--ignore-registry-errors` is not used.
5. Updates happen through deliberate `pnpm update` by a human, reviewed like any change.
6. Every remote GitHub Action is pinned to a full 40-hex commit SHA, resolved from the
   upstream tag. The repository's no-comments rule means no trailing tag marker; the
   tag-to-SHA map is recorded in the pinning pull request.

`scripts/ci/check-supply-chain-policy.sh`, run as a Phase 0 job, enforces controls 2, 3
and 6 and forbids Renovate configuration and `.github/dependabot.yml`, so the policy
cannot drift silently. Dependabot security alerts (notify-only) are enabled later
through `infra/github` OpenTofu, tracked separately.

## Audit Ignore List

Configured in `pnpm-workspace.yaml` `auditConfig.ignoreGhsas`. Each entry is a
production advisory with no fix reachable inside the declaring package's version
constraint at a release at least 7 days old (checked 2026-10-04). Review date for all
entries: 2027-01-04, or earlier when the named parent publishes a release that lifts
the constraint.

| Advisory | Package (locked) | Patched | Why no fix is reachable | Review |
|---|---|---|---|---|
| GHSA-6g55-p6wh-862q | `postcss@8.4.31` via `next` | `>=8.5.12` | `next@15.5.24`, `15.5.25` and `15.5.26` all declare `postcss: 8.4.31` exactly; next 16 is a major upgrade outside this policy change | 2027-01-04 |
| GHSA-r28c-9q8g-f849 | `postcss@8.4.31` via `next` | `>=8.5.18` | same as above | 2027-01-04 |
| GHSA-ggr8-5vv4-36mx | `deepmerge-ts@7.1.5` via `prisma` > `@prisma/config` | `>=8.0.0` | `@prisma/config@7.8.0` and `@7.10.0` (latest 7.x at least 7 days old) declare `deepmerge-ts: 7.1.5` exactly | 2027-01-04 |
| GHSA-3f6p-5ww8-9rcr | `mysql2@3.15.3` via `prisma` | `>=3.22.0` | `prisma@7.8.0` and `@7.10.0` declare `mysql2: 3.15.3` exactly; this project's datasource `provider` is `postgresql` | 2027-01-04 |

## Consequences

- No bot PRs, no automerge path for third-party code. Exposure to a freshly compromised
  release drops to releases older than 7 days that a human chose.
- Dependencies age unless someone updates them. Known-vulnerable production versions are
  surfaced by the audit gate; dev-only advisories and non-security staleness are visible
  but accepted.
- `main` can turn red without a code change when a new high advisory is published
  against a production dependency. That is the intended signal; remediation is a
  normal PR.
- Urgent security patches younger than 7 days need `minimumReleaseAgeExclude` for the
  named package, which is a visible, reviewable exception.
- Action SHAs no longer float; refreshing them is manual work, and the version each SHA
  represents is not visible in the workflow file.
- `renovate.json`, `.github/workflows/renovate.yml`, `scripts/ci/check-renovate-token.sh`
  and its BATS suite are removed. `RENOVATE_TOKEN` is no longer a bootstrap secret.
- Constitution non-negotiable 15 ("Renovate weekday-only") is replaced by "No automated
  dependency-update bots; updates are deliberate with a >= 7-day release cooldown", and
  16 is reworded so that human-initiated major upgrades carry the `needs-adr-review`
  label. The label stays; its description drops the Renovate reference.
- tgh-template should receive the same decision and the formal supersession of ADR 0021
  (ThomasGHenry/tgh-template#36).

## Hypothesis

With the policy check and audit gate in place, no Renovate or Dependabot configuration,
no sub-7-day package version, and no tag-pinned remote action can reach `main`. Confirmed
when `commit-validation` fails on a PR that reintroduces any of them, and passes on
`main` after implementation.

## Findings

Implemented 2026-10-04 through PRs merged to `main` in sequence:

- #72 (`d3edfd7`, #71): `next` 15.5.20 → 15.5.24; `pnpm audit --prod --audit-level=critical`
  exit 1 (2 critical) → exit 0.
- #73 (`cfc2334`): this ADR, spec, plan, tasks.
- #74 (`cc380da`, #66): Renovate removed; `check-supply-chain-policy.sh` Phase 0 job.
- #75 (`0d6252e`, #67): pnpm 10.11.0 → 10.34.5; top-level `minimumReleaseAge: 10080`,
  `trustPolicy: no-downgrade`, `blockExoticSubdeps: true`, `shamefullyHoist: true`;
  `.npmrc` removed. Root `node_modules` entry count unchanged (871) after a fresh install.
- #76 (`ae75e9f`, #68): 49 `uses:` references across 7 workflows pinned to commit SHAs
  (11 distinct actions).
- #77 (`4791c7b`, #69): in-range updates of `fast-uri`, `browserslist`, `nanoid`, `sharp`;
  four advisories ignored (table above); `pnpm-audit` Phase 0 job.

Audit counts, production dependencies: 2 critical / 20 high (`1c9ef82`) → 0 critical /
4 high, all four ignored (`4791c7b`). All dependencies, high: 59 → 43 (non-blocking).

Hypothesis status: the policy check fails on each forbidden shape in its BATS suite
(31 tests) and passes on `main`; `commit-validation` succeeded on every PR above. A PR
that reintroduces a violation has not yet been observed in CI.

Not covered: `trustPolicy` and `minimumReleaseAge` are evaluated only during resolution;
`pnpm install --frozen-lockfile` skips resolution, so they bind at deliberate
`pnpm update`/`add`. Observed in #77: resolution locked `browserslist@4.29.1`
(2026-09-24) while `4.29.2` (2026-09-28) and `4.29.3` (2026-09-29) existed, both younger
than 10080 minutes. Dependabot security alerts remain follow-up #70.
