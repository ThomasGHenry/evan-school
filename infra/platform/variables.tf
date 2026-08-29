variable "project_name" {
  description = "Project slug used for Neon project and Vercel project names"
  type        = string
}

variable "repo_owner" {
  description = "GitHub username or org owning the repository"
  type        = string
}

variable "repo_name" {
  description = "GitHub repository name (without owner prefix)"
  type        = string
}

variable "neon_api_key" {
  description = "Neon API key (from Neon dashboard)"
  type        = string
  sensitive   = true
}

variable "vercel_token" {
  description = "Vercel API token with project creation scope"
  type        = string
  sensitive   = true
}

variable "github_token" {
  description = "GitHub token with repo secrets write scope (from GitHub App)"
  type        = string
  sensitive   = true
}

variable "cf_r2_access_key_id" {
  description = "Cloudflare R2 account-scoped access key ID (for infra.yml Tofu state backend)"
  type        = string
  sensitive   = true
}

variable "cf_r2_secret_access_key" {
  description = "Cloudflare R2 account-scoped secret access key (for infra.yml Tofu state backend)"
  type        = string
  sensitive   = true
}

variable "gh_auto_merge_app_id" {
  description = "GitHub App ID for blm-auto-merge (used by auto-merge.yml and infra.yml)"
  type        = string
}

variable "gh_auto_merge_app_private_key" {
  description = "GitHub App RSA private key (PEM) for blm-auto-merge"
  type        = string
  sensitive   = true
}
