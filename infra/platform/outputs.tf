output "vercel_project_id" {
  description = "Vercel project ID — set as VERCEL_PROJECT_ID repo variable"
  value       = vercel_project.main.id
}

output "neon_connection_uri" {
  description = "Neon Postgres connection URI"
  value       = neon_project.main.connection_uri
  sensitive   = true
}
