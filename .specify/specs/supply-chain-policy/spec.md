# Spec: Deliberate supply-chain controls replace automated dependency updates

Tracking issue: #65. Children: #66, #67, #68, #69. Follow-up (not in scope): #70.
ADR: `docs/adr/0124-deliberate-supply-chain-controls.md`.

## Feature

As the project owner, I want third-party code to enter the repository only through
deliberate human choices that are checked automatically, so that a freshly compromised
upstream release cannot reach production through an update bot or a floating reference.

## Background

An update bot currently is configured to raise and automerge minor/patch updates. The
owner has decided to remove it and rely on: a committed lockfile, a 7-day release
cooldown on package installs, a known-advisory gate in CI, deliberate human updates, and
CI action references fixed to immutable identifiers. Today none of the replacement
controls is active, and the configuration that would provide the cooldown is not
supported by the package manager version in use.

## User Scenarios

### S1 — Bot configuration cannot return unnoticed (#66)

- GIVEN a change that adds an update-bot configuration file WHEN CI runs THEN the change
  fails with a message naming the file.
- GIVEN the repository after this feature WHEN inspected THEN it contains no update-bot
  configuration, workflow, token check, or setup instructions for one.

### S2 — New package releases wait 7 days (#67)

- GIVEN the workspace configuration WHEN CI runs THEN it fails unless a release cooldown
  of at least 7 days is configured where the package manager reads it.
- GIVEN the cooldown is configured WHEN the package manager version in use does not
  support it THEN CI fails.
- GIVEN the cooldown is active WHEN a developer installs dependencies THEN versions
  published less than 7 days ago are not installed.

### S3 — CI actions are immutable references (#68)

- GIVEN a workflow referencing a remote action by tag or branch WHEN CI runs THEN it
  fails naming the file, line and reference.
- GIVEN a workflow referencing a local action WHEN CI runs THEN it passes.

### S4 — Known high-severity advisories block merges (#69)

- GIVEN the lockfile contains a dependency with a high or critical advisory WHEN CI runs
  THEN it fails.
- GIVEN the gate is introduced WHEN it first runs on `main` THEN it passes (remediation
  precedes the gate).

## Success Criteria

- SC1: No update-bot configuration exists, and adding one fails CI.
- SC2: A release cooldown of >= 10080 minutes is active for every install, enforced by CI.
- SC3: 100% of remote action references in workflows are full commit identifiers.
- SC4: A known-advisory gate at high severity runs on every push and is part of the
  single required status check.
- SC5: Every existing CI job continues to pass; the single required status check is
  unchanged.

## Out of Scope

- Enabling notify-only security alerts (follow-up #70, requires infrastructure bootstrap
  #29 and the IaC pipeline).
- Rewording constitution non-negotiables 15 and 16 (owner decision; see plan Open
  Questions).
- Changing template meta-ADR 0021 (template-owned; upstream concern).
- Upstreaming to tgh-template (noted; separate repository).

## Open Questions (owner)

- Q1: Advisory gate scope — all dependencies or production only; policy for advisories
  with no patched version.
- Q2: Adopt `trustPolicy: no-downgrade` and `blockExoticSubdeps: true` alongside the
  cooldown (requires a newer package manager than the cooldown alone).
- Q3: Wording of constitution non-negotiables 15 and 16 after the bot is removed.
