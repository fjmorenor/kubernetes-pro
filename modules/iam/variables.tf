# =============================================================================
# VARIABLES DEL MÓDULO: IAM (IDENTIDAD Y ACCESOS)
# =============================================================================

# 1. ID DEL PROYECTO
variable "project_id" {
  description = "ID del proyecto de GCP. Se recibe del Main principal para saber dónde crear la identidad."
  type        = string
}

# 2. IDENTIFICADOR TÉCNICO DE LA CUENTA
variable "sa_id" {
  description = "El ID que tendrá la cuenta de servicio (ej: 'gke-nodes-sa'). Es la parte que va antes del @."
  type        = string
  
  # VALIDACIÓN: Google Cloud tiene reglas estrictas para los nombres de las cuentas.
  # Esta lógica evita que Terraform falle a mitad del proceso si pones un nombre inválido.
  validation {
    condition     = can(regex("^[a-z0-9-]{1,30}$", var.sa_id))
    error_message = "El sa_id solo permite minúsculas, números y guiones (máx 30 caracteres)."
  }
}

# 3. NOMBRE VISIBLE EN CONSOLA
variable "sa_display_name" {
  description = "Nombre amigable (ej: 'Cuenta para Nodos de GKE'). Es lo que verás en la interfaz de Google Cloud."
  type        = string
  default     = "" # Si no lo pones, el código usará el sa_id por defecto.
}

# 4. DESCRIPCIÓN DE LA FUNCIÓN
variable "sa_description" {
  description = "Explica para qué sirve esta cuenta. Muy útil para auditorías futuras."
  type        = string
}

# 5. LISTA DE PERMISOS (ROLES)
variable "roles" {
  description = "Lista de permisos que tendrá la cuenta (ej: ['roles/logging.logWriter', 'roles/monitoring.metricWriter'])."
  type        = list(string)
  default     = []
  
  # CONECTA CON: El recurso 'google_project_iam_member' en el main.tf del módulo.
}

# 6. INTERRUPTOR DE WORKLOAD IDENTITY
variable "enable_workload_identity_user" {
  description = "Si es 'true', permite que un Pod de Kubernetes use esta identidad de Google."
  type        = bool
  default     = false
}

# 7. MIEMBRO DE KUBERNETES PARA EL VÍNCULO
variable "workload_identity_member" {
  description = "Define qué Namespace y qué Service Account de K8s pueden usar esta identidad."
  type        = string
  default     = ""
  
  # FORMATO REQUERIDO: serviceAccount:ID_PROYECTO.svc.id.goog[NAMESPACE/KSA]
}