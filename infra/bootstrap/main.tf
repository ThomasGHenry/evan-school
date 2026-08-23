terraform {
  required_version = ">= 1.6"
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
  }
}

provider "cloudflare" {
  # Credentials via env: CLOUDFLARE_API_KEY + CLOUDFLARE_EMAIL
}

resource "cloudflare_r2_bucket" "terraform_state" {
  account_id = var.cf_account_id
  name       = var.state_bucket_name
}
