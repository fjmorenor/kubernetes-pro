# =============================================================================
# RECURSO 1: CLOUD ROUTER (EL CEREBRO DE ENRUTAMIENTO)
# =============================================================================
# El Router es la base lógica necesaria. No traduce IPs por sí mismo, sino que
# gestiona las tablas de rutas regionales para que el NAT pueda funcionar.
resource "google_compute_router" "router" {
  # Recibe del Main: var.project_id, var.region y var.vpc_name.
  # Conecta con: La VPC específica para interceptar el tráfico que no es interno.
  project = var.project_id
  name    = "router-${var.vpc_name}"
  region  = var.region
  network = var.vpc_name

  # QUE HACE: Establece un identificador de red (ASN) privado. 
  # Aunque no usemos BGP para hablar con otros routers, es un requisito 
  # de Google Cloud para que el recurso Router sea válido.
  bgp {
    asn = 64514 # Identificador privado estándar (no entra en conflicto con Internet).
  }
}

# =============================================================================
# RECURSO 2: CLOUD NAT (LA PUERTA DE SALIDA A INTERNET)
# =============================================================================
# Este es el componente que realmente realiza la traducción (NAT). 
# Permite que recursos con IP privada (Nodos y Pods) salgan a Internet.
resource "google_compute_router_nat" "nat" {
  # Recibe del Main: var.project_id y var.region.
  # Conecta con: El recurso 'google_compute_router' creado justo arriba.
  project = var.project_id
  name    = "nat-${var.vpc_name}"
  router  = google_compute_router.router.name
  region  = var.region

  # QUE HACE: Define cómo se obtienen las IPs públicas para salir a la calle.
  # Recibe del Main: var.nat_ip_allocate_option (normalmente "AUTO_ONLY").
  # Conecta con: El pool de direcciones IP públicas gestionado por Google.
  nat_ip_allocate_option = var.nat_ip_allocate_option

  # QUE HACE: Especifica qué subredes y qué rangos pueden usar esta salida.
  # Recibe del Main: var.source_subnetwork_ip_ranges_to_nat.
  # Conecta con: Los rangos primarios (Nodos) y secundarios (Pods) de tu subred.
  source_subnetwork_ip_ranges_to_nat = var.source_subnetwork_ip_ranges_to_nat

  # QUE HACE: Configura la visibilidad de las conexiones salientes.
  # Recibe del Main: var.enable_logging.
  # Conecta con: Cloud Logging para auditar fallos de conexión sin generar altos costes.
  log_config {
    enable = var.enable_logging
    filter = "ERRORS_ONLY" # Solo registra cuando un Pod no puede conectar fuera.
  }
}