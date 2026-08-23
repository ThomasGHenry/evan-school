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
