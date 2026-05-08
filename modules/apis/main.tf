# =============================================================================
# DEFINICIÓN DE VARIABLES LOCALES: ORGANIZACIÓN DE APIs POR FUNCIÓN
# =============================================================================
# Las variables locales preparan la lista de servicios que Google debe activar 
# antes de que los módulos de Red, GKE o IAM intenten crear recursos.
locals {
  # LISTA COMÚN: Servicios base para cualquier proyecto de infraestructura.
  apis_common = [
    "compute.googleapis.com",              # Conecta con: Módulo Network, Firewall y NAT.
    "container.googleapis.com",            # Conecta con: Módulo GKE-Standard (Control Plane).
    "iam.googleapis.com",                  # Conecta con: Módulo IAM (Service Accounts).
    "logging.googleapis.com",              # Conecta con: Sistema de auditoría de todos los módulos.
    "monitoring.googleapis.com",           # Conecta con: Métricas de salud del Cluster.
    "cloudresourcemanager.googleapis.com", # Conecta con: Terraform (para gestionar el proyecto).
  ]

  # LISTA HOST: APIs específicas para la gestión de red centralizada.
  apis_host = [
    "servicenetworking.googleapis.com",  # Conecta con: SQL y Servicios Privados (VPC Peering).
    "dns.googleapis.com",                # Conecta con: Resolución de nombres interna.
  ]

  # LISTA DEV: APIs para el entorno donde residen las aplicaciones.
  apis_dev = [
    "artifactregistry.googleapis.com",  # Conecta con: El despliegue de contenedores (YAML).
    "autoscaling.googleapis.com",       # Conecta con: El escalado de nodos en GKE.
  ]

  # LÓGICA DE COMBINACIÓN:
  # Recibe del Main: var.mode ("host" o "dev") y var.extra_apis.
  # QUE HACE: Fusiona las listas, elimina duplicados (distinct) y entrega una lista final.
  apis_to_enable = distinct(concat(
    local.apis_common,
    var.mode == "host" ? local.apis_host : local.apis_dev,
    var.extra_apis
  ))
}

# =============================================================================
# RECURSO 1: HABILITACIÓN DE SERVICIOS (EL INTERRUPTOR)
# =============================================================================
resource "google_project_service" "apis_common" {
    # Bucle: Se ejecuta una vez por cada API definida en la lógica de 'locals'.
    for_each = toset(local.apis_to_enable)

    # Recibe del Main: var.project_id.
    project = var.project_id
    service = each.value

    # QUE HACE: Activa formalmente el servicio en el proyecto.
    # Si var.disable_on_destroy es 'false', las APIs siguen activas tras borrar el cluster.
    disable_on_destroy = var.disable_on_destroy 
}

# =============================================================================
# RECURSO 2: PAUSA DE PROPAGACIÓN (EL TEMPORIZADOR)
# =============================================================================
# Google Cloud no siempre activa las APIs de forma instantánea. 
# Este recurso evita errores de "API_NOT_ENABLED" en los siguientes pasos.
resource "time_sleep" "wait_apis" {
    # Conecta con: El recurso 'google_project_service' de arriba.
    depends_on = [ google_project_service.apis_common ]
    
    # QUE HACE: Detiene la ejecución de Terraform por 10 segundos.
    # Esto garantiza que cuando el módulo de Red o GKE empiece, la API ya sea funcional.
    create_duration = "10s"
}