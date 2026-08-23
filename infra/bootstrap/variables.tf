variable "cf_account_id" {
  description = "Cloudflare account ID that owns the R2 bucket"
  type        = string
}

variable "state_bucket_name" {
  description = "Name for the R2 bucket that holds Terraform state for all modules"
  type        = string
}
