# Plan: Deliberate supply-chain controls

Spec: `.specify/specs/supply-chain-policy/spec.md`. ADR: `docs/adr/0124-deliberate-supply-chain-controls.md`.
Issues: #65 (parent), #66, #67, #68, #69. #70 is a follow-up outside this plan.

## Verified facts this plan depends on

| Fact | Source |
|---|---|
| pnpm in use is `10.11.0` | `package.json:6` `"packageManager": "pnpm@10.11.0"`; `pnpm --version` |
| `minimumReleaseAge` added v10.16.0, minutes, top-level | pnpm/pnpm.io `docs/settings/dependency-resolution.md` ("Added in: v10.16.0"), https://pnpm.io/settings |
| `minimumReleaseAgeExclude` added v10.16.0, `string[]` | same file |
| `trustPolicy` added v10.21.0, `no-downgrade` \| `off` | same file |
| `blockExoticSubdeps` added v10.26.0 | same file |
| No `security:` nesting is documented | same file; tgh-template `c60fc00:pnpm-workspace.yaml` uses one |
| Current pnpm docs: "Only auth and registry settings are read from `.npmrc` files." (introducing version not stated in the docs read) | pnpm/pnpm.io `docs/settings.md`; this repo's `.npmrc` has `shamefully-hoist=true` |
| Latest pnpm 10.x: `10.34.6` (published 2026-09-28), `10.34.5` (2026-07-10) | `npm view pnpm dist-tags`, `npm view pnpm time` |
| `pnpm audit --audit-level=high` exits 1 on `main`: 59 high, 2 critical; `--prod`: 20 high, 2 critical | local run on `1c9ef82` |
| After PR #72 (`next@15.5.24`): `pnpm audit --prod --audit-level=high` 1 low, 15 moderate, 17 high, 0 critical | local run on `d3edfd7` |
| `pnpm audit` severity flag: `--audit-level <low\|moderate\|high\|critical>`; `--prod`; `--ignore-registry-errors` | pnpm/pnpm.io `docs/cli/audit.md` |
| tgh-template audit gate added `3e2f971`, reverted `19917a5` | `git -C ~/code/tgh-template log` |
| Phase 0 jobs are listed in every Phase 1 `needs:` and in `commit-validation` `needs:` | `.github/workflows/1-commit.yml:142,158,174,190,232` |
| Shell CI scripts use `SCRIPT_DIR` + `lib/common.sh` (`die`, `add_violation`, `report_violations`) | `scripts/ci/lib/common.sh`, `scripts/ci/validate-adrs.sh` |

## Decisions

### D1 — Single policy check script: `scripts/ci/check-supply-chain-policy.sh` + `.bats`

Rules, each added by its own red-green-refactor cycle:

- R1 no bot config: fail if any of `renovate.json`, `renovate.json5`, `.renovaterc`,
  `.renovaterc.json`, `.renovaterc.json5`, `.github/renovate.json`,
  `.github/renovate.json5`, `.gitlab/renovate.json`, `.gitlab/renovate.json5`,
  `.github/dependabot.yml`, `.github/dependabot.yaml` exists, or `package.json` has a
  top-level `renovate` key.
- R2 install policy: fail unless `pnpm-workspace.yaml` has, as top-level keys,
  `minimumReleaseAge` as an integer >= 10080, `trustPolicy: no-downgrade`, and
  `blockExoticSubdeps: true`. Nested occurrences (e.g. under `security:`) do not count.
- R3 pnpm supports R2: fail if `package.json` `packageManager` is `pnpm@X.Y.Z` with
  `X.Y.Z < 10.26.0` (first version supporting `blockExoticSubdeps`).
- R4 SHA pins: fail for any `uses:` in `.github/workflows/*.y*ml` and
  `.github/actions/**/action.y*ml` whose reference is not exactly
  `owner/repo[/path]@<40 hex>` with nothing after it on the line; `./`-prefixed local
  actions and `docker://` references pass (no `docker://` exist today).
- R5 settings location: fail if `.npmrc` contains `shamefully-hoist`, and fail unless
  `pnpm-workspace.yaml` has top-level `shamefullyHoist: true`.

YAML for R2 is read with `python3` + `yaml.safe_load`, the same dependency
`validate-speckit.sh:25` already uses. `package.json` is read with `python3 json`.
Violations accumulate via `add_violation` and print together via `report_violations`.

Justification against the constitution's rule (abstraction only for an earned scar or a
named current experiment):

- R1: drift scar. `renovate.json` persisted with automerge after owner discussions on
  2026-08-23, 2026-08-28, 2026-09-19 rejected it.
- R2/R3: concrete scar. tgh-template `c60fc00` shipped a cooldown that is a silent no-op
  (unsupported nesting, unsupported pnpm version) and every CI check passed.
- R4: scar in `.planning/codebase/CONCERNS.md:151-154` (floating action tag), and the only
  maintainer of pins (Renovate `helpers:pinGitHubActionDigests`) is being removed.
- R5: owner decision Q3 (2026-10-04); current pnpm docs read only auth/registry settings
  from `.npmrc`, so a hoisting setting there is a latent break on the next major.
- One script, not five: the five rules share one subject (supply-chain policy), one
  ADR, and one CI job. Splitting would add four jobs to five `needs:` arrays each.

Alternatives considered: rely on code review only (rejected: the `c60fc00` scar passed
review); use a third-party action-pinning linter such as `zizmor` or
`ratchet` (rejected: adds a new third-party supply-chain dependency to defend the supply
chain; no sister-project precedent).

### D2 — pnpm audit as inline workflow steps, no wrapper script

The `pnpm-audit` job is `pnpm/action-setup` + `actions/setup-node` + two steps:

1. `pnpm audit --dev --audit-level=high` with `continue-on-error: true` (reported,
   non-blocking).
2. `pnpm audit --prod --audit-level=high` (blocking).

No `install` is needed; audit reads `pnpm-lock.yaml`. Unfixable advisories go in
`auditConfig.ignoreGhsas` in `pnpm-workspace.yaml` (the pnpm 10 name; pnpm/pnpm.io
`docs/cli/audit.md`: "Before v11.16.0, these settings were named `auditLevel` and
`auditConfig.ignoreGhsas`"), each listed in ADR 0124 with reason and review date. No
`--ignore-registry-errors`. A `run-pnpm-audit.sh` wrapper would mirror `run-gitleaks.sh`,
but those wrappers exist for mode handling and a binary-presence check; `pnpm` is
already required by every other job. No scar justifies a wrapper. The red step is the
observed local `exit 1`; the green step is remediation.

### D3 — pnpm target: newest 10.x at least 7 days old, and >= 10.26.0

Stay on major 10. Current pnpm docs (v11/v12 era) say only auth and registry settings are
read from `.npmrc`; moving `shamefullyHoist` (R5) removes that risk but a major bump
remains a separate decision. Re-verify publish dates with `npm view pnpm time` at the
time of the change (on 2026-10-04: `10.34.5` 2026-07-10 qualifies; `10.34.6` 2026-09-28
does not).

### D4 — Sequencing so CI never lands red

Each PR-sized slice adds a rule and the repo change that satisfies it together. The
policy job is wired into `1-commit.yml` in the first slice, so later rules are enforced
the moment they are written. The audit job is wired only after remediation.

### D5 — ADR 0021 is not edited

`validate-adrs.sh` `check_superseded_status` fails a `supersedes:` link unless the target
has `status: superseded`; `CLAUDE.md` forbids modifying 0001-0099 in instances. ADR 0124
references 0021 in prose only. Formal supersession is an upstream task.

## Completeness surface (qreview preamble)

- Config: `pnpm-workspace.yaml`, `package.json` `packageManager`, `pnpm-lock.yaml`
  header, deletion of `renovate.json`.
- Workflows: `1-commit.yml` (new Phase 0 jobs, every Phase 1 `needs:`,
  `commit-validation` `needs:`), all workflows for SHA pins, deletion of `renovate.yml`.
- Scripts: new `check-supply-chain-policy.sh`/`.bats`; deletion of
  `check-renovate-token.sh`/`.bats` in the same commit (keeps `validate-bats-coverage` green).
- Docs: `docs/BOOTSTRAP.md:174-188,252`, `docs/github/secrets.md:12`,
  `.github/LABEL_TAXONOMY.md:20`, `CLAUDE.md` CI pipeline section (Phase 0 list, Bootstrap
  step 4), `.specify/memory/constitution.md` CI Gate list, Tech Stack pnpm row, and
  non-negotiables 15/16.
- IaC: `infra/github/main.tf:94` `needs-adr-review` label stays; description loses any
  Renovate reference (applied by the pipeline, not locally). Dependabot alerts are #70.
- ADR: 0124 to `accepted` with `implementation: scripts/ci/check-supply-chain-policy.sh`.
- Not touched: `.planning/codebase/*` (point-in-time analysis snapshots), ADR 0021, ADR
  0028 prose.

## Resolved Decisions (owner, 2026-10-04)

- Q1 (#69): blocking gate is `--prod --audit-level=high`; dev findings non-blocking;
  unfixable advisories in `auditConfig.ignoreGhsas` and listed in ADR 0124 with reason
  and review date; no `--ignore-registry-errors` (a real registry failure stops work).
- Q2 (#67): adopt `trustPolicy: no-downgrade` and `blockExoticSubdeps: true`.
- Q3: non-negotiable 15 becomes "No automated dependency-update bots; updates are
  deliberate with a >= 7-day release cooldown"; 16 reworded to match; `needs-adr-review`
  label kept, Renovate reference removed from `.github/LABEL_TAXONOMY.md` and
  `infra/github/main.tf`. `shamefully-hoist` moves to `shamefullyHoist` (R5).
- Q4: R1 forbids `.github/dependabot.yml`.
- Q5: action pins are SHA-only; tag-to-SHA map goes in the PR body.
- Prerequisite done: #71 / PR #72 moved `next` to `15.5.24` (criticals cleared).

## Implementation order

See `tasks.md`. Slices, one issue → one branch → one PR, merged sequentially: S1 (#66) → S2 (#67) → S3 (#68) → S4 (#69) → S5 docs + ADR accept.
