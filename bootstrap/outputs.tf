output "wif_provider_name" {
  value = google_iam_workload_identity_pool_provider.github_provider.name
}

output "github_sa_email" {
  value = module.sa_github
}

output "project_id" {
  value = var.project_id
}