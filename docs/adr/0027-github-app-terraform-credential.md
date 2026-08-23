---
status: accepted
date: 2026-07-07
tags: [tooling, architecture]
implementation: infra/bootstrap/main.tf
---

# 0027. GitHub App for Terraform and Auto-Merge Credentials

## Context

Fine-grained PATs expire silently and are tied to individual users. GitHub Apps issue
short-lived tokens per job, are scoped to specific repositories, and have no expiry
management burden. BLM adopted this pattern (ADR-0111) after the initial PAT-based
bootstrap approach proved fragile.

## Decision

Use a GitHub App (`GH_AUTO_MERGE_APP_ID` + `GH_AUTO_MERGE_APP_PRIVATE_KEY`) for both:
1. Auto-merge workflow (`.github/workflows/auto-merge.yml`) — creates a short-lived
   token via `actions/create-github-app-token@v1` to enable squash auto-merge
2. Tofu IaC (`.github/workflows/infra.yml`) — same token creation step before
   `tofu plan`/`tofu apply`

Add `prevent_destroy = true` lifecycle guard on credential-related Tofu resources.

## Consequences

- One GitHub App covers both auto-merge and IaC; no separate PATs to manage
- App tokens expire after 1 hour; short-lived by design
- `GH_AUTO_MERGE_APP_ID` is a repo variable (not secret); `GH_AUTO_MERGE_APP_PRIVATE_KEY`
  is a repo secret
- `prevent_destroy = true` prevents accidental credential destruction via `tofu destroy`
