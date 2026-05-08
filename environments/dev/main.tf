# =============================================================================
# MÓDULO: HABILITACIÓN DE APIS (PROYECTO SERVICE/DEV)
# =============================================================================
module "apis" {
  # Qué hace: Activa servicios específicos para el proyecto de desarrollo.
  #           A diferencia del Host, aquí se habilitan herramientas de cómputo y registro[cite: 36].
  source     = "../../modules/apis"
  
  # Recibe del Main: El ID del proyecto de destino (Service Project)[cite: 24, 28].
  project_id = var.project_id
  
  # Recibe del Main: El perfil 'dev' para activar Artifact Registry y Autoscaling[cite: 24, 36].
  mode       = "dev"
}

# =============================================================================
# MÓDULO: IAM - SERVICE ACCOUNT PARA NODOS
# =============================================================================
module "sa_gke_nodes" {
  # Qué hace: Crea la identidad (Service Account) que usarán las máquinas del cluster[cite: 54].
  #           Sin esta identidad y sus roles, los nodos no pueden reportar logs ni métricas[cite: 55].
  source          = "../../modules/iam"
  
  project_id      = var.project_id
  
  # Recibe del Main: ID único y descripción para la gestión de identidad[cite: 59].
  sa_id           = "sa-gke-nodes"
  sa_description  = "SA para nodos de GKE Standard"
  sa_display_name = "GKE Nodes Service Account"

  # Recibe del Main: Lista de permisos mínimos necesarios para la operación del nodo[cite: 60, 64].
  # Conecta con: 
  # - Cloud Logging: Para escribir registros de sistema[cite: 64].
  # - Cloud Monitoring: Para enviar métricas de salud[cite: 35].
  # - Cloud Storage: Para descargar imágenes de contenedores[cite: 36].
  roles = [
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
    "roles/monitoring.viewer",
    "roles/storage.objectViewer",
  ]

  # Conecta con: El módulo 'apis'. La API de IAM debe estar activa para crear identidades[cite: 35, 37].
  depends_on = [module.apis]
}

# =============================================================================
# MÓDULO: GKE STANDARD (COMPUTE ENGINE)
# =============================================================================
module "gke_standard" {
  # Qué hace: Despliega el cluster de Kubernetes gestionado[cite: 143]. 
  #           Configura el Control Plane y el Node Pool bajo estándares de seguridad[cite: 143].
  source           = "../../modules/gke-standard"
  
  project_id       = var.project_id
  region           = var.region
  cluster_name     = var.cluster_name

  # --- VÍNCULO CON SHARED VPC ---
  # Recibe del Main: Los links de la red creada en el proyecto Host[cite: 145].
  # Conecta con: El proyecto Host para "aterrizar" el cluster en la red corporativa[cite: 176].
  vpc_self_link    = var.vpc_self_link
  subnet_self_link = var.subnet_standard_self_link

  # --- DIRECCIONAMIENTO DE K8S ---
  # Recibe del Main: Los nombres de los rangos secundarios definidos en la red compartida[cite: 145].
  # Conecta con: Los rangos 'pods-standard' y 'services-standard' para la VPC Nativa[cite: 156, 162].
  pods_range_name     = "subnet-pods"
  services_range_name = "subnet-service"

  # --- CONFIGURACIÓN DE NODOS ---
  # Conecta con: El módulo 'sa_gke_nodes' mediante su output 'email'[cite: 80, 81].
  node_sa_email    = module.sa_gke_nodes.email

  # Recibe del Main: Especificaciones de hardware y límites de escalado[cite: 146].
  # Conecta con: Compute Engine para el aprovisionamiento de recursos físicos[cite: 159].
  machine_type     = var.machine_type
  min_nodes        = var.min_nodes
  max_nodes        = var.max_nodes

  # Conecta con: El módulo 'sa_gke_nodes'. El cluster no puede iniciarse sin su identidad[cite: 199, 200].
  depends_on       = [module.sa_gke_nodes]
}