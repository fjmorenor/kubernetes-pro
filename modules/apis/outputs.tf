# =============================================================================
# OUTPUTS DEL MÓDULO: ENABLED-APIS
# =============================================================================
# Estos valores permiten confirmar el estado de los servicios y orquestar el
# orden de ejecución de los demás módulos (Network, GKE, IAM).

# -----------------------------------------------------------------------------
# 1. LISTA DE APIS ACTIVAS
# -----------------------------------------------------------------------------
output "enabled_apis" {
  description = "Lista completa de los nombres de las APIs que el módulo ha activado."
  # El bucle 'for' recorre los recursos creados para extraer solo el nombre del servicio.
  value       = [for svc in google_project_service.apis_common : svc.service]

  # DONDE CONECTARÁ:
  # Se enviará al Main Principal. Su uso principal es informativo y de auditoría.
  # También sirve para que Terraform sepa que este módulo ha terminado su trabajo.
}

# -----------------------------------------------------------------------------
# 2. CONTADOR DE SERVICIOS
# -----------------------------------------------------------------------------
output "apis_count" {
  description = "Número total de servicios que se han mandado a habilitar."
  value       = length(google_project_service.apis_common)

  # DONDE CONECTARÁ:
  # Se enviará al Main Principal. Es útil para validaciones rápidas en la consola
  # tras un 'terraform apply' para asegurar que el modo (host/dev) inyectó
  # la cantidad correcta de APIs.
}

# -----------------------------------------------------------------------------
# 3. SEÑAL DE FINALIZACIÓN (IMPORTANTE)
# -----------------------------------------------------------------------------
# Aunque no lo pusiste en tu bloque original, es una práctica recomendada:
output "wait_finished" {
  description = "Salida técnica que confirma que la pausa de 10s ha terminado."
  value       = time_sleep.wait_apis.id

  # DONDE CONECTARÁ:
  # Este es el "enchufe" de sincronización. En el Main Principal lo usarás así:
  # module "network" {
  #   depends_on = [module.enabled_apis.wait_finished]
  # }
  # Esto garantiza que el módulo Network espere a que las APIs se propaguen.
}