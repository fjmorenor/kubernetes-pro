# =============================================================================
# RECURSO 1: ACTIVACIÓN DEL PROYECTO HOST
# =============================================================================
# Este recurso designa formalmente a un proyecto como "Anfitrión" de la red.
# Es el paso previo obligatorio para poder compartir subredes con otros proyectos.
resource "google_compute_shared_vpc_host_project" "host" {
  # Recibe del Main: var.host_project_id (ej: "zafa-host-123").
  # Conecta con: El API de Compute Engine para habilitar la capacidad de Shared VPC.
  project = var.host_project_id
  
  # QUE HACE: Activa la funcionalidad de "Hosting" en el proyecto. 
  # A partir de este momento, las redes de este proyecto pueden ser "vistas"
  # por los proyectos de servicio que tú autorices.
}

# =============================================================================
# RECURSO 2: VÍNCULO DEL PROYECTO DE SERVICIO (DEV)
# =============================================================================
# Este recurso conecta el proyecto donde vivirán tus aplicaciones (Dev)
# con el proyecto que gestiona la red (Host).
resource "google_compute_shared_vpc_service_project" "dev" {
  # Conecta con: El recurso host_project creado justo arriba.
  # Esto garantiza que el proyecto host esté listo antes de intentar vincular el servicio.
  host_project    = google_compute_shared_vpc_host_project.host.project
  
  # Recibe del Main: var.service_project_id (ej: "zafa-dev-456").
  service_project = var.service_project_id
  
  # QUE HACE: Crea una relación de confianza administrativa. 
  # Permite que el proyecto 'Dev' utilice los recursos de red del proyecto 'Host'
  # como si fueran propios, pero manteniendo la administración centralizada.
}