# =============================================================================
# VARIABLES DEL MÓDULO: FIREWALL
# =============================================================================

# 1. ID DEL PROYECTO
variable "project_id" {
  description = "ID del proyecto de GCP donde se aplicarán las reglas de firewall."
  type        = string
  # RECIBE DEL MAIN: var.project_id
}

# 2. NOMBRE DE LA RED VPC
variable "vpc_name" {
  description = "Nombre de la red donde se aplicarán las reglas (ej: 'vpc-prod')."
  type        = string
  # RECIBE DEL MAIN: El nombre o ID de la red generado por el módulo 'network'.
}

# 3. RANGO DE RED DEL MASTER (CONTROL PLANE)
variable "master_ipv4_cidr" {
  description = "Rango de IPs privado del Master de Kubernetes gestionado por Google."
  type        = string
  default     = "172.16.0.0/28"
  
  # PARA QUÉ SE USA: Esta variable debe coincidir EXACTAMENTE con la que definas 
  # en el módulo GKE. Se usa para que los nodos confíen en el tráfico que viene del Master.
}

# 4. INTERRUPTOR: COMUNICACIÓN MASTER -> NODOS
variable "enable_master_to_nodes" {
  description = "Si es true, crea la regla para que el Master gestione los nodos (logs, exec)."
  type        = bool
  default     = true
  
  # CONECTA CON: El bloque 'count' del recurso 'allow_master_to_nodes' en el main.tf.
}

# 5. INTERRUPTOR: HEALTH CHECKS
variable "enable_health_checks" {
  description = "Si es true, permite que los Balanceadores de Google verifiquen si los nodos están sanos."
  type        = bool
  default     = true
  
  # CONECTA CON: El bloque 'count' del recurso 'allow_health_checks' en el main.tf.
  # NOTA: Sin esto, los servicios expuestos a Internet (Load Balancers) no funcionarán.
}