output "state_bucket_name" {
  description = "R2 bucket name — use in infra/github/backend.tf and infra/platform/backend.tf"
  value       = cloudflare_r2_bucket.terraform_state.name
}

output "state_bucket_endpoint" {
  description = "R2 S3-compatible endpoint — use in backend.tf files"
  value       = "https://${var.cf_account_id}.r2.cloudflarestorage.com"
}
