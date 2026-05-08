provider "google" {
    project = var.project_id
    region = var.region
}

provider "google" {
    alias = "host"
    project = var.host_project_id
    region = var.region
}

module "sa_github" {
  source = "../modules/iam"
  project_id = var.host_project_id
  sa_id = "sa-github"
  sa_display_name = "Service Account para Github"
  sa_description = "Cuenta de servicio para Github"

 roles = [ 
    "roles/container.admin",                # Permite gestionar clústeres de Kubernetes (GKE) en DEV.
    "roles/compute.networkAdmin",           # Permite configurar firewalls y subredes locales en DEV.
    "roles/storage.admin",                  # Permite guardar archivos en los Buckets de DEV.
    "roles/iam.serviceAccountUser",         # Permite "actuar como" otras cuentas (necesario para GKE).
    "roles/resourcemanager.projectIamAdmin",
    "roles/artifactregistry.admin",
    "roles/artifactregistry.reader",
    "roles/serviceusage.serviceUsageAdmin",
    "roles/compute.networkAdmin",
    "roles/compute.securityAdmin",
    "roles/serviceusage.serviceUsageAdmin"
  ]
}

resource "google_project_iam_member" "host_storage_access" {
    provider = google.host
    project = var.host_project_id
    role = "roles/storage.admin"
    member = "serviceAccount:${module.sa_github.email}"

    depends_on = [ module.sa_github ]
    
}

resource "google_project_iam_member" "host_network_access" {
    provider = google.host
    project = var.host_project_id
    role = "roles/compute.networkAdmin"
    member = "serviceAccount:${module.sa_github.email}"
    
}

# =============================================================================
# INFRAESTRUCTURA BASE: WORKLOAD IDENTITY FEDERATION
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

# =============================================================================
# VÍNCULO DE CONFIANZA (EL PUENTE)
# =============================================================================
resource "google_service_account_iam_member" "github_wif_binding" {
  # Conecta con: La SA creada mediante el módulo IAM
  service_account_id = module.sa_github.name
  role               = "roles/iam.workloadIdentityUser"

  # Recibe del Main: Filtro estricto por repositorio
  # IMPORTANTE: Reemplaza con tu REPO real antes de subir a GitHub
  member = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github_pool.name}/attribute.repository/fjmorenor/kubernetes-pro"
}