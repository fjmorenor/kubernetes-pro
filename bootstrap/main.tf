provider "google" {
  project = var.project_id # Proyecto DEV
  region  = var.region
}

provider "google" {
  alias   = "host"
  project = var.host_project_id # Proyecto HOST
  region  = var.region
}

# =============================================================================
# 1. CREACIÓN DE LA SERVICE ACCOUNT (Solo una vez, en el proyecto HOST)
# =============================================================================
module "sa_github" {
  source          = "../modules/iam"
  project_id      = var.host_project_id
  sa_id           = "sa-github"
  sa_display_name = "Service Account para Github"
  sa_description  = "Cuenta de servicio centralizada para CI/CD"

  # Roles dentro del proyecto HOST (Red y Almacenamiento de State)
  roles = [
    "roles/compute.networkAdmin",
    "roles/compute.securityAdmin",
    "roles/storage.admin",
    "roles/serviceusage.serviceUsageAdmin",
    "roles/iam.workloadIdentityUser",
    "roles/storage.admin",
    "roles/resourcemanager.projectIamAdmin"
  ]
}

# =============================================================================
# 2. PERMISOS EN EL PROYECTO DEV (El "Puente" de roles)
# =============================================================================
resource "google_project_iam_member" "github_sa_dev_permissions" {
  for_each = toset([
    "roles/container.admin",                # Poder total sobre GKE
    "roles/serviceusage.serviceUsageAdmin", # Poder activar APIs en DEV
    "roles/compute.admin",                  # Poder crear los nodos del clúster
    "roles/iam.serviceAccountUser",         # Poder usar las SAs de los nodos
    "roles/resourcemanager.projectIamAdmin",# Poder gestionar permisos en DEV
    "roles/artifactregistry.admin",
    "roles/iam.serviceAccountAdmin"         # Poder subir imágenes Docker
  ])

  project = var.project_id # ID del proyecto DEV
  role    = each.key
  member  = "serviceAccount:${module.sa_github.email}" 

  depends_on = [module.sa_github]
}


# Permiso explícito sobre el bucket del estado
resource "google_storage_bucket_iam_member" "state_iam" {
  bucket = "bucket-zafa-host-zafa"
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${module.sa_github.email}"

  depends_on = [module.sa_github]
}
# =============================================================================
# 3. WORKLOAD IDENTITY FEDERATION (WIF)
# =============================================================================
resource "google_iam_workload_identity_pool" "github_pool" {
  workload_identity_pool_id = "github-actions-pool-v2"
  display_name              = "GitHub Actions Pool"
}

resource "google_iam_workload_identity_pool_provider" "github_provider" {
  workload_identity_pool_id          = google_iam_workload_identity_pool.github_pool.workload_identity_pool_id
  workload_identity_pool_provider_id = "github-provider-v2"
  
  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }

  attribute_mapping = {
    "google.subject"             = "assertion.sub"
    "attribute.repository"       = "assertion.repository"
    "attribute.repository_owner" = "assertion.repository_owner"
  }

  attribute_condition = "assertion.repository_owner == 'fjmorenor'"
}

# Vincular WIF con la SA creada
resource "google_service_account_iam_member" "github_wif_binding" {
  service_account_id = module.sa_github.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github_pool.name}/attribute.repository/fjmorenor/kubernetes-pro"
}

# 1. Obtener los datos del proyecto DEV para sacar el ID numérico
data "google_project" "dev_project" {
  project_id = var.project_id # El ID de zafa-dev-zafa
}

# 2. Dar permiso al Agente de Servicio de GKE de DEV sobre el proyecto HOST
resource "google_project_iam_member" "gke_agent_network_user" {
  project = var.host_project_id # zafa-host-zafa
  role    = "roles/compute.networkUser"
  member  = "serviceAccount:service-${data.google_project.dev_project.number}@container-engine-robot.iam.gserviceaccount.com"
}

# 3. Dar permiso también a la Service Account de GitHub sobre la red del HOST
# (Para que Terraform pueda "leer" la subred al planificar)
resource "google_project_iam_member" "github_sa_network_viewer" {
  project = var.host_project_id
  role    = "roles/compute.networkUser"
  member  = "serviceAccount:${module.sa_github.email}"
}

