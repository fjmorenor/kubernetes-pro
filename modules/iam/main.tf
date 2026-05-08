# =============================================================================
# RECURSO 1: LA IDENTIDAD (SERVICE ACCOUNT)
# =============================================================================
# Crea la cuenta de servicio que actuará como el "usuario" para tus procesos.
resource "google_service_account" "sa" {
  # Recibe del Main: var.project_id
  # Conecta con: El inventario de identidades de tu proyecto en GCP.
  project      = var.project_id
  account_id   = var.sa_id
  
  # Lógica: Si no defines un nombre amigable, usa el ID técnico.
  display_name = var.sa_display_name != "" ? var.sa_display_name : var.sa_id
  description  = "Identidad gestionada por Terraform para nodos o aplicaciones"
}

# =============================================================================
# RECURSO 2: ASIGNACIÓN DE ROLES (PERMISOS A NIVEL DE PROYECTO)
# =============================================================================
# Este bloque otorga los permisos necesarios (como escribir logs o leer de Storage).
resource "google_project_iam_member" "roles" {
  # Recibe del Main: var.roles (una lista de strings como ["roles/logging.logWriter"])
  # Conecta con: El motor de IAM de Google Cloud para autorizar acciones.
  
  # Bucle: Se ejecuta una vez por cada rol que hayas puesto en la lista.
  for_each = toset(var.roles)

  project = var.project_id
  role    = each.value
  
  # Conecta con: El recurso Service Account de arriba mediante su email.
  member  = "serviceAccount:${google_service_account.sa.email}"
}

