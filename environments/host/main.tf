# =============================================================================
# MÓDULO: HABILITACIÓN DE APIS
# =============================================================================
module "apis" {
  # Qué hace: Activa los servicios de Google Cloud necesarios para que el proyecto 
  # funcione. Sin esto, Terraform no tiene permisos para crear nada[cite: 19, 20].
  source     = "../../modules/apis"
  
  # Recibe del Main: El ID del proyecto donde se activarán los servicios[cite: 28].
  project_id = var.project_id
  
  # Recibe del Main: El perfil 'host' para habilitar APIs de red compartida[cite: 29].
  mode       = "host"
}

# =============================================================================
# MÓDULO: RED PRIVADA (VPC Y SUBNETS)
# =============================================================================
module "network" {
  # Qué hace: Crea la columna vertebral de la infraestructura. Define la VPC y 
  # las subredes con rangos para nodos, pods y servicios[cite: 85, 86].
  source     = "../../modules/network"
  
  # Recibe del Main: ID del proyecto y nombre deseado para la red[cite: 88].
  project_id = var.project_id
  vpc_name   = var.vpc_name

  # --- CONFIGURACIÓN DE SUBREDES ---
  # Define el direccionamiento IP primario (nodos) y secundario (K8s)[cite: 91, 92].
  subnets = [ {
    name   = "subnet-gke-standard"
    cidr   = var.subnet_primary_cidr # IPs para las máquinas físicas (nodos)[cite: 185].
    region = var.region
    
    secondary_ip_ranges = [ 
      {
        # Recibe del Main: Nombre y rango CIDR para los contenedores (Pods)[cite: 186].
        range_name    = var.subnet_pods_name
        ip_cidr_range = var.subnet_pods_cidr
      },
      {
        # Recibe del Main: Nombre y rango CIDR para los balanceadores internos (Services)[cite: 187].
        range_name    = var.subnet_services_name
        ip_cidr_range = var.subnet_services_cidr
      }
    ]
  }]

  # Conecta con: El módulo 'apis'. No intenta crear la red hasta que el API de Compute esté lista[cite: 197, 200].
  depends_on = [ module.apis ]
}

# =============================================================================
# MÓDULO: REGLAS DE FIREWALL
# =============================================================================
module "firewall" {
  # Qué hace: Controla quién puede comunicarse dentro de la VPC. Bloquea todo 
  # por defecto y permite solo lo necesario[cite: 110, 111].
  source     = "../../modules/firewall"
  
  project_id = var.project_id
  
  # Conecta con: El módulo 'network'. Extrae dinámicamente el nombre de la VPC creada[cite: 197].
  vpc_name   = var.vpc_name
  
  # Define el rango IP del Control Plane para que Google pueda administrar los nodos[cite: 120].
  master_ipv4_cidr = "172.16.0.0/28"
  
  # Conecta con: Los Load Balancers de Google para permitir monitoreo de salud[cite: 123].
  enable_health_checks = true
  
  # Seguridad: Mantenemos el acceso directo del Master desactivado para forzar uso de proxies/bastiones.
  enable_master_to_nodes = false

  # Conecta con: El módulo 'network'. La red debe existir antes de aplicar reglas sobre ella[cite: 198].
  depends_on = [ module.network ]
}

# =============================================================================
# MÓDULO: SALIDA A INTERNET (CLOUD NAT)
# =============================================================================
module "cloud_nat" {
  # Qué hace: Permite que los nodos y pods sin IP pública puedan descargar 
  # actualizaciones o imágenes externas de Docker[cite: 127, 128].
  source     = "../../modules/cloud-nat"
  
  project_id = var.project_id
  region     = var.region
  
  # Conecta con: El módulo 'network' para saber en qué VPC debe actuar el Router[cite: 133].
  vpc_name   = module.network.vpc_self_link

  # Recibe del Main: Configuración para que Google asigne IPs públicas automáticamente[cite: 130].
  nat_ip_allocate_option = "AUTO_ONLY"
  
  # Conecta con: Cloud Logging. Registra errores de conexión para debugging de red[cite: 134].
  enable_logging         = true

  # Conecta con: El módulo 'network'. Requiere que la VPC y sus rutas estén activas[cite: 198].
  depends_on = [ module.network ]
}