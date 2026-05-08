# =============================================================================
# VARIABLES DEL MÓDULO: GKE STANDARD
# =============================================================================

variable "cluster_name" {
  description = "Nombre único del cluster de Kubernetes"
  type        = string
}

variable "vpc_self_link" {
  description = "Self-link de la VPC (proviene del output del módulo network)"
  type        = string
}

variable "subnet_self_link" {
  description = "Self-link de la subnet donde residirán los nodos"
  type        = string
}

variable "pods_range_name" {
  description = "Nombre del rango secundario de IPs destinado a los Pods"
  type        = string
}

variable "node_sa_email" {
  description = "Email de la Service Account creada en el módulo IAM para los nodos"
  type        = string
}

variable "machine_type" {
  description = "Tipo de instancia para los nodos (ej: e2-medium)"
  type        = string
}

variable "min_nodes" {
  description = "Número mínimo de nodos para el auto-scaling"
  type        = number
  
}

variable "max_nodes" {
  description = "Número máximo de nodos para el auto-scaling"
  type        = number
  
}

variable "enable_private_nodes" {
  description = "Si es true, los nodos no tendrán direcciones IP públicas (Seguridad)"
  type        = bool
  default     = true
}

variable "enable_private_endpoint" {
    type = bool
    default = true
}

variable "enable_workload_identity" {
  description = "Habilita la unión segura entre Service Accounts de K8s y GCP"
  type        = bool
  default     = true
}

variable "enable_network_policy" {
  description = "Habilita el control de tráfico interno mediante Network Policies"
  type        = bool
  default     = true
}

variable "release_channel" {
  description = "Canal de actualizaciones: RAPID, REGULAR o STABLE"
  type        = string
  default     = "REGULAR"
}

variable "disk_size_gb" {
    type = number
    default = 15
}

variable "disk_type" {
    type = string
    default = "pd-balanced"
}

variable "region" {
    type = string
}

variable "project_id" {
    type = string
}

variable "services_range_name" {
    type = string
}