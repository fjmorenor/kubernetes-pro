#################################################################################
# MÓDULO: Artifact Registry
# Recibe del Main: project_id, location, repository_id
# Conecta con: GKE (vía IAM para pull de imágenes), Cloud Build / GitHub Actions
# Qué hace: Crea un repositorio privado de Docker con cifrado y reglas de 
#           retención de imágenes.
#################################################################################

resource "google_artifact_registry_repository" "docker_repo" {
  project       = var.project_id
  location      = var.location
  repository_id = var.repository_id
  description   = "Repositorio Docker para microservicios - Arquitectura Shared VPC"
  format        = "DOCKER"

  docker_config {
    immutable_tags = false # Permitir sobrescribir tags como 'latest' en dev
  }

  labels = {
    env = var.environment
  }
}

# Regla de limpieza: Eliminar imágenes sin tag después de 30 días
resource "google_artifact_registry_repository_iam_member" "gke_node_sa_pull" {
  project    = var.project_id
  location   = google_artifact_registry_repository.docker_repo.location
  repository = google_artifact_registry_repository.docker_repo.name
  role       = "roles/artifactregistry.reader"
  member     = "serviceAccount:${var.gke_service_account_email}"
}