terraform {
  backend "s3" {
    bucket                      = "PLACEHOLDER-state-bucket-name"
    key                         = "github/terraform.tfstate"
    region                      = "auto"
    endpoint                    = "https://PLACEHOLDER-cf-account-id.r2.cloudflarestorage.com"
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    use_path_style              = true
  }
}
