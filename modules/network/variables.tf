# --- VARIABLES DEL MÓDULO DE RED (NETWORK) ---
# Define la estructura de la VPC y las subredes con sus rangos para Kubernetes.

variable "project_id" {
  description = "ID del proyecto de GCP donde se creará la red"
  type        = string
}

variable "vpc_name" {
  description = "Nombre de la red privada virtual (VPC)"
  type        = string
  default     = "vpc-kubernetes"
}

variable "subnets" {
  description = "Lista de subredes. Incluye nombre, CIDR principal, región y rangos secundarios para Pods/Servicios."
  type = list(object({
    name   = string
    cidr   = string  # Ejemplo: "10.10.0.0/24"
    region = string  # Ejemplo: "europe-west1"
    secondary_ip_ranges = optional(list(object({
      range_name    = string # Ejemplo: "pods-standard"
      ip_cidr_range = string # Ejemplo: "10.20.0.0/16"
    })), [])
  }))
}

variable "routing_mode" {
  description = "Modo de enrutamiento: REGIONAL (recomendado) o GLOBAL"
  type        = string
  default     = "REGIONAL"
}