---
status: proposed
date: 2026-10-04
tags: [tooling, ci, dependencies, security]
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
  `19917a5` for the same two advisories.
- Every workflow `uses:` reference is tag-pinned (for example `actions/checkout@v4`).

This ADR deliberately does not use the `supersedes:` frontmatter key. `validate-adrs.sh`
`check_superseded_status` requires the superseded ADR to carry `status: superseded`, and
`CLAUDE.md` marks ADRs 0001-0099 as template meta-ADRs not to be modified in instances.
ADR 0021 is overridden for this instance by this ADR; the formal supersession belongs
upstream in tgh-template.

## Decision

We will not run any automated dependency-update bot (Renovate, or Dependabot version
updates). Dependency currency becomes a deliberate human act backed by five controls:

1. `pnpm-lock.yaml` remains the source of truth for resolved versions.
2. `minimumReleaseAge: 10080` (7 days) as a top-level key in `pnpm-workspace.yaml`, with
   `packageManager` raised to a pnpm version that supports it.
3. `pnpm audit --audit-level=high` runs as a Phase 0 job in `1-commit.yml`, landed only
   after `main` audits clean.
4. Updates happen through deliberate `pnpm update` by a human, reviewed like any change.
5. Every remote GitHub Action is pinned to a full 40-hex commit SHA, with the tag in a
   trailing reference, refreshed deliberately.

A `scripts/ci/check-supply-chain-policy.sh` Phase 0 check enforces 1, 2 and 5 so the
policy cannot drift silently. Dependabot security alerts (notify-only) are enabled later
through `infra/github` OpenTofu, tracked separately.

## Consequences

- No bot PRs, no automerge path for third-party code. Supply-chain exposure to a
  freshly compromised release drops to releases older than 7 days that a human chose.
- Dependencies age unless someone updates them. Known-vulnerable versions are surfaced
  by the audit gate; non-security staleness is accepted.
- `main` can turn red without a code change when a new high advisory is published
  against the lockfile. That is the intended signal; remediation is a normal PR.
- Urgent security patches younger than 7 days need `minimumReleaseAgeExclude` for the
  named package, which is a visible, reviewable exception.
- Action SHAs no longer float; refreshing them is manual work.
- `renovate.json`, `.github/workflows/renovate.yml`, `scripts/ci/check-renovate-token.sh`
  and its BATS suite are removed. `RENOVATE_TOKEN` is no longer a bootstrap secret.
- Constitution non-negotiable 15 ("Renovate weekday-only") becomes obsolete and 16
  (major updates get `needs-adr-review`) loses its automated applier. Both need an owner
  decision on rewording.
- tgh-template should receive the same decision and the formal supersession of ADR 0021.

## Hypothesis

With the policy check and audit gate in place, no Renovate or Dependabot configuration,
no sub-7-day package version, and no tag-pinned remote action can reach `main`. Confirmed
when `commit-validation` fails on a PR that reintroduces any of them, and passes on
`main` after implementation.
