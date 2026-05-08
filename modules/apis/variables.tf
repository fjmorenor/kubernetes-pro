# =============================================================================
# VARIABLES DEL MÓDULO: ENABLED-APIS
# =============================================================================

# 1. ID DEL PROYECTO
variable "project_id" {
  description = "ID del proyecto de GCP donde se activarán los servicios."
  type        = string
  # RECIBE DEL MAIN: var.project_id.
  # FUNCIÓN: Indica sobre qué contenedor administrativo (proyecto) actuar.
}

# 2. MODO DE OPERACIÓN (HOST vs DEV)
variable "mode" {
  description = "Determina el perfil de APIs: 'host' (redes/infra) o 'dev' (cluster/apps)."
  type        = string
  
  # VALIDACIÓN: Garantiza que solo se pasen valores que el módulo sabe manejar.
  validation {
    condition     = contains(["host", "dev"], var.mode)
    error_message = "El modo debe ser exclusivamente 'host' (para red compartida) o 'dev' (para clusters)."
  }
  # FUNCIÓN: Conecta con la lógica de 'locals' en el main.tf para filtrar las listas de APIs.
}

# 3. SEGURIDAD AL DESTRUIR
variable "disable_on_destroy" {
  description = "¿Apagar las APIs cuando se destruye la infraestructura con Terraform?"
  type        = bool
  default     = false
  
  # FUNCIÓN: Si se deja en 'false' (recomendado), las APIs seguirán activas aunque borres
  # los recursos. Esto evita pérdida de cuotas o errores al intentar recrear rápido.
}

# 4. APIs ADICIONALES (EXTENSIBILIDAD)
variable "extra_apis" {
  description = "Lista de servicios extra que no están en los perfiles por defecto."
  type        = list(string)
  default     = []
  
  # RECIBE DEL MAIN: Una lista como ["sqladmin.googleapis.com", "redis.googleapis.com"].
  # FUNCIÓN: Permite habilitar servicios específicos sin modificar el código del módulo.
}