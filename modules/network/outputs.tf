# =============================================================================
# OUTPUTS DEL MÓDULO: NETWORK (VPC Y SUBREDES)
# =============================================================================
# Estos valores actúan como el "enchufe" de salida de este módulo.
# El Main Principal (environments/host/main.tf) los recolectará para 
# conectarlos a los módulos de GKE, Firewall y NAT.

# -----------------------------------------------------------------------------
# 1. URL DE LA RED VPC
# -----------------------------------------------------------------------------
output "vpc_self_link" {
  description = "URL completa de la red VPC creada."
  value       = google_compute_network.vpc.self_link

  # DONDE CONECTARÁ: 
  # Se enviará al Main Principal y este lo repartirá a:
  # - Módulo Firewall: Para saber qué red proteger.
  # - Módulo Cloud NAT: Para saber en qué red crear el Router.
  # - Módulo GKE: Para situar el cluster en esta red.
}

# -----------------------------------------------------------------------------
# 2. CATÁLOGO ORGANIZADO DE SUBREDES (MAPA)
# -----------------------------------------------------------------------------
output "subnets_map" {
  description = "Mapa detallado que organiza cada subred por el nombre que le diste en el Main."
  
  # Este bucle 'for' transforma los datos técnicos de Google en un catálogo fácil de leer.
  value = {
    for name, subnet in google_compute_subnetwork.subnets : name => {
      id        = subnet.id        # ID único del recurso en GCP.
      self_link = subnet.self_link # URL técnica necesaria para GKE.
      cidr      = subnet.ip_cidr_range # Rango de IPs de los nodos.
      region    = subnet.region    # Región física donde vive la subred.
      
      # Mapeo de rangos secundarios (IPs de Pods y Servicios de Kubernetes)
      secondary_ranges = {
        for sr in subnet.secondary_ip_range : sr.range_name => sr.ip_cidr_range
      }
    }
  }

  # DONDE CONECTARÁ:
  # El Main Principal recibirá este catálogo y usará la "llave" (el nombre de la subred)
  # para extraer el 'self_link' y pasárselo al Módulo GKE.
  
  # EJEMPLO DE USO EN EL MAIN:
  # subnet_self_link = module.network.subnets_map["tu-nombre-de-subred"].self_link
}