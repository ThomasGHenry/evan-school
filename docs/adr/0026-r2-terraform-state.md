---
status: accepted
date: 2026-07-07
tags: [tooling, architecture]
implementation: infra/bootstrap/main.tf
---

# 0026. Cloudflare R2 for Terraform State Backend

## Context

The original template used GCS as the Terraform remote state backend (placeholder,
never applied). BLM discovered GCS requires a GCP project and service account before
Tofu can run — a bootstrap dependency problem. Cloudflare R2 is simpler: one account,
free 10GB tier, S3-compatible API, no IAM configuration.

## Decision

Use Cloudflare R2 as the Terraform state backend for all modules (`infra/github/`,
`infra/platform/`). The R2 bucket is created by `infra/bootstrap/` using local state
(the bootstrap exception). All subsequent modules reference the R2 bucket via S3
backend configuration.

## Consequences

- Requires `CLOUDFLARE_API_KEY` + `CLOUDFLARE_EMAIL` + `CF_ACCOUNT_ID` at bootstrap time
- State is stored in `<project>-tofu-state` R2 bucket; key per module
- `use_path_style = true` + skip_* flags required for R2's S3 compatibility quirks
- No GCP dependency for state management
