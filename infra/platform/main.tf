terraform {
  required_version = ">= 1.6"
  required_providers {
    neon = {
      source  = "kislerdm/neon"
      version = "~> 0.13"
    }
    vercel = {
      source  = "vercel/vercel"
      version = "~> 5.0"
    }
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
  }
}

provider "neon" {
  api_key = var.neon_api_key
}

provider "vercel" {
  api_token = var.vercel_token
}

provider "github" {
  token = var.github_token
  owner = var.repo_owner
}

resource "neon_project" "main" {
  name       = var.project_name
  region_id  = "aws-us-east-2"
  pg_version = 17
}

resource "vercel_project" "main" {
  name      = var.project_name
  framework = "nextjs"

  git_repository = {
    type = "github"
    repo = "${var.repo_owner}/${var.repo_name}"
  }

  root_directory             = "apps/web"
  auto_assign_custom_domains = false
}

resource "vercel_project_environment_variable" "database_url_build" {
  project_id = vercel_project.main.id
  team_id    = vercel_project.main.team_id
  key        = "DATABASE_URL"
  value      = neon_project.main.connection_uri
  target     = ["preview"]
  sensitive  = true
}

resource "github_actions_secret" "database_url_prod" {
  repository      = var.repo_name
  secret_name     = "DATABASE_URL_PROD"
  plaintext_value = neon_project.main.connection_uri

  lifecycle {
    prevent_destroy = true
  }
}

resource "github_actions_secret" "vercel_token" {
  repository      = var.repo_name
  secret_name     = "VERCEL_TOKEN"
  plaintext_value = var.vercel_token

  lifecycle {
    prevent_destroy = true
  }
}

resource "github_actions_variable" "vercel_project_id" {
  repository    = var.repo_name
  variable_name = "VERCEL_PROJECT_ID"
  value         = vercel_project.main.id
}
