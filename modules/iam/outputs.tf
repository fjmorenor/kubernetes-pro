# =============================================================================
# OUTPUTS DEL MÓDULO: IAM (IDENTIDAD Y PERMISOS)
# =============================================================================

# -----------------------------------------------------------------------------
# 1. EMAIL DE LA SERVICE ACCOUNT
# -----------------------------------------------------------------------------
output "email" {
  description = "Dirección de correo de la Service Account creada."
  value       = google_service_account.sa.email

  # DONDE CONECTARÁ: 
  # Este es el dato más importante. Se enviará al Main Principal para:
  # - Inyectarlo en el módulo 'gke-standard': Los nodos se identificarán con este email.
  # - Usarlo en otros módulos: Si necesitas que esta cuenta tenga permisos en un Bucket o DB.
}

# -----------------------------------------------------------------------------
# 2. NOMBRE COMPLETO DEL RECURSO (ID TÉCNICO)
# -----------------------------------------------------------------------------
output "name" {
  description = "Nombre del recurso en formato: projects/{project}/serviceAccounts/{email}"
  value       = google_service_account.sa.name

  # DONDE CONECTARÁ:
  # Se enviará al Main Principal y se usará principalmente para:
  # - Referencias de recursos de IAM internos: Como el recurso 'google_service_account_iam_member' 
  #   que configura Workload Identity, ya que este pide el ID completo, no solo el email.
}

# -----------------------------------------------------------------------------
# 3. ID ÚNICO (NUMÉRICO)
# -----------------------------------------------------------------------------
output "unique_id" {
  description = "ID numérico único asignado por Google Cloud."
  value       = google_service_account.sa.unique_id

  # DONDE CONECTARÁ:
  # Se enviará al Main Principal. Suele usarse para:
  # - Auditorías y Logs: Es un identificador que no cambia aunque borres y crees la cuenta con el mismo nombre.
  # - Políticas de seguridad avanzadas: Donde el email podría ser ambiguo.
}