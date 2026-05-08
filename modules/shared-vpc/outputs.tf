# =============================================================================
# OUTPUTS DEL MÓDULO: SHARED-VPC
# =============================================================================
# Estos valores confirman que el proyecto Host ha sido habilitado correctamente
# para compartir su red con otros proyectos de servicio.

# -----------------------------------------------------------------------------
# 1. ID DEL PROYECTO HOST CONFIRMADO
# -----------------------------------------------------------------------------
output "host_project_id" {
  description = "El ID del proyecto que ahora actúa como Host de la VPC Compartida."
  value       = var.host_project_id

  # DONDE CONECTARÁ:
  # Se enviará al Main Principal (environments/host/main.tf).
  # FUNCIÓN TÉCNICA: Sirve como "bandera" de sincronización. Otros módulos que
  # dependan de que la red esté compartida (como la creación del cluster GKE
  # en el proyecto de servicio) usarán este output para asegurar que el 
  # vínculo administrativo ya existe antes de empezar a trabajar.
}