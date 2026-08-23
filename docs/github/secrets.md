# Required Secrets and Variables

## GitHub Repository Secrets

| Secret | Required by | Description |
|---|---|---|
| `GH_AUTO_MERGE_APP_PRIVATE_KEY` | `auto-merge.yml`, `infra.yml` | GitHub App private key for auto-merge and Tofu credentials |
| `CF_R2_ACCESS_KEY_ID` | `infra.yml` | Cloudflare R2 access key for Terraform state backend |
| `CF_R2_SECRET_ACCESS_KEY` | `infra.yml` | Cloudflare R2 secret key for Terraform state backend |
| `VERCEL_TOKEN` | `2-e2e.yml`, `3-promote.yml` | Vercel API + CLI authentication |
| `DATABASE_URL_PROD` | `3-promote.yml` | Production database connection string |
| `RENOVATE_TOKEN` | `renovate.yml` | Fine-grained PAT for Renovate PRs |

## GitHub Repository Variables

| Variable | Required by | Description |
|---|---|---|
| `GH_AUTO_MERGE_APP_ID` | `auto-merge.yml`, `infra.yml` | GitHub App ID (not sensitive — stored as variable, not secret) |
| `VERCEL_PROJECT_ID` | `2-e2e.yml`, `3-promote.yml` | Vercel project ID (set by `infra/platform/` Tofu apply) |

## Bootstrap Credentials (one-time, not stored in GitHub)

| Credential | Used for | Store in |
|---|---|---|
| `CLOUDFLARE_API_KEY` + `CLOUDFLARE_EMAIL` | `infra/bootstrap/` — creates R2 bucket | Bitwarden |
| GitHub App private key (PEM) | Create GitHub App in GitHub UI | Bitwarden, then set as `GH_AUTO_MERGE_APP_PRIVATE_KEY` |
| `NEON_API_KEY` | `infra/platform/` — creates Neon project | Bitwarden |

## OpenTofu State Backend

After running `infra/bootstrap/`, update `infra/github/backend.tf` and `infra/platform/backend.tf`
with the R2 bucket name and Cloudflare account ID from the bootstrap output.
