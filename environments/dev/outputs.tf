output "gke_standard_endpoint" {
  value = module.gke_standard.endpoint
  sensitive = true
}