# =============================================================================
# VARIABLES DEL MÓDULO: CLOUD NAT
# =============================================================================

# 1. ID DEL PROYECTO
variable "project_id" {
  description = "ID del proyecto de GCP donde se desplegará la infraestructura de NAT."
  type        = string
  # RECIBE DEL MAIN: var.project_id.
  # FUNCIÓN: Define la ubicación administrativa de los recursos.
}

# 2. REGIÓN GEOGRÁFICA
variable "region" {
  description = "Región de GCP (ej: europe-west1). Debe coincidir con la región de la VPC y el GKE."
  type        = string
  # RECIBE DEL MAIN: var.region.
  # FUNCIÓN: El NAT es un recurso regional; solo puede dar servicio a subredes de su misma región.
}

# 3. NOMBRE DE LA RED VPC
variable "vpc_name" {
  description = "Nombre de la red VPC a la que se vinculará el Cloud Router."
  type        = string
  # RECIBE DEL MAIN: El nombre de la red generado por el módulo 'network'.
  # FUNCIÓN: Conecta el Router y el NAT a la red privada para "escuchar" el tráfico de salida.
}

# 4. MÉTODO DE ASIGNACIÓN DE IP PÚBLICA
variable "nat_ip_allocate_option" {
  description = "Define si Google asigna IPs automáticas (AUTO_ONLY) o si usas IPs reservadas (MANUAL_ONLY)."
  type        = string
  default     = "AUTO_ONLY"
  # RECIBE DEL MAIN: Habitualmente se deja en el valor por defecto.
  # FUNCIÓN: Determina la identidad pública que verá Internet cuando tus Pods salgan fuera.
}

# 5. ALCANCE DE LA TRADUCCIÓN (IPs INCLUIDAS)
variable "source_subnetwork_ip_ranges_to_nat" {
  description = "Define qué rangos de la subred tienen permitido usar el NAT."
  type        = string
  default     = "ALL_SUBNETWORKS_ALL_IP_RANGES"
  # RECIBE DEL MAIN: El valor por defecto es el recomendado para GKE.
  # FUNCIÓN: Permite que tanto Nodos como Pods (rangos secundarios) tengan acceso a Internet.
}

# 6. INTERRUPTOR DE AUDITORÍA (LOGS)
variable "enable_logging" {
  description = "Activa o desactiva el registro de conexiones en Cloud Logging."
  type        = bool
  default     = true
  # RECIBE DEL MAIN: var.enable_logging.
  # FUNCIÓN: Conecta con el sistema de monitoreo para registrar errores de conexión saliente.
}