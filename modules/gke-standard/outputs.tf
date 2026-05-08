# Este output lo recibirá el Main principal para identificar el cluster en otros procesos
output "cluster_name" {
  description = "Nombre del cluster. Se usará en el Main principal para referenciar este cluster en otros recursos."
  value       = google_container_cluster.cluster.name
}

# Este output lo recibirá el Main principal para configurar la conexión del provider 'kubernetes'
output "endpoint" {
  description = "IP del Master. El Main principal la usará para que Terraform pueda gestionar objetos dentro de K8s."
  value       = google_container_cluster.cluster.endpoint
  sensitive   = true
}

# Este output lo recibirá el Main principal para reportar la versión exacta instalada
output "master_version" {
  description = "Versión de GKE. Usada por el Main principal para verificar compatibilidades de software."
  value       = google_container_cluster.cluster.master_version
}

# Este output lo recibirá el Main principal como confirmación de seguridad
output "workload_identity_enabled" {
  description = "Confirmación de Workload Identity. El Main principal lo usa para validar permisos de Pods."
  value       = google_container_cluster.cluster.workload_identity_config[0].workload_pool != null
}

# Este output es para TI. Aparecerá en tu consola al terminar el proceso.
output "kubeconfig_command" {
  description = "Comando de conexión. Lo usarás tú manualmente en tu terminal para activar kubectl."
  value       = "gcloud container clusters get-credentials ${google_container_cluster.cluster.name} --region ${var.region} --project ${var.project_id}"
}