# --- CREACIÓN DE LA RED VIRTUAL (VPC) ---
resource "google_compute_network" "vpc" {
  name                    = var.vpc_name
  auto_create_subnetworks = false # Control total sobre las subredes
  routing_mode            = var.routing_mode
  project                 = var.project_id
}

# --- CREACIÓN DE SUBREDES CON RANGOS PARA KUBERNETES ---
resource "google_compute_subnetwork" "subnets" {
  # Crea tantas subredes como hayamos definido en la variable 'subnets'
  for_each = { for s in var.subnets : s.name => s } 
  
  project       = var.project_id
  name          = each.value.name
  ip_cidr_range = each.value.cidr   # Rango para los NODOS
  region        = each.value.region
  network       = google_compute_network.vpc.id

  # Permite que nodos privados hablen con APIs de Google sin Internet público
  private_ip_google_access = true

  # BLOQUE DINÁMICO: Crea rangos extras para PODS y SERVICIOS
  dynamic "secondary_ip_range" {
    for_each = each.value.secondary_ip_ranges
    content {
      range_name    = secondary_ip_range.value.range_name
      ip_cidr_range = secondary_ip_range.value.ip_cidr_range
    }
  }
}