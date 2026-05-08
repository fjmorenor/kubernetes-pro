# =============================================================================
# RECURSO: CLUSTER DE KUBERNETES (CONTROL PLANE)
# =============================================================================
resource "google_container_cluster" "cluster" {
  # Recibe del Main: var.project_id, var.region
  # Conecta con: Google API Beta para habilitar cifrado de base de datos y Workload Identity.
  provider = google-beta

  name     = var.cluster_name
  location = var.region

  # --- NETWORKING ---
  # Recibe del Main: var.vpc_self_link y var.subnet_self_link (vienen del módulo 'network').
  # Conecta con: La infraestructura de red para situar el cluster en el edificio virtual correcto.
  network    = var.vpc_self_link
  subnetwork = var.subnet_self_link

  # Recibe del Main: var.pods_range_name y var.services_range_name (vienen del módulo 'network').
  # Conecta con: Los rangos secundarios de la subred para asignar IPs reales a los Pods.
  networking_mode = "VPC_NATIVE"
  ip_allocation_policy {
    cluster_secondary_range_name  = var.pods_range_name
    services_secondary_range_name = var.services_range_name
  }

  # --- PRIVACIDAD ---
  # Recibe del Main: var.enable_private_nodes y var.enable_private_endpoint.
  # Conecta con: Cloud NAT (para salida a internet) y Firewall (para el acceso vía kubectl).
  private_cluster_config {
    enable_private_nodes    = var.enable_private_nodes # Si es true, oculta nodos de internet.
    enable_private_endpoint = var.enable_private_endpoint # Si es false, expone el Master para admin.
    master_ipv4_cidr_block  = "172.16.0.0/28" # Crea un puente de red interno con Google.
  }

  # --- WORKLOAD IDENTITY ---
  # Recibe del Main: var.project_id.
  # Conecta con: El módulo IAM para permitir que los Pods hereden permisos de Google Cloud.
  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  # --- ADDONS ---
  # Recibe del Main: var.enable_network_policy.
  # Conecta con: El motor de red interno de K8s para filtrar tráfico entre contenedores.
  addons_config {
    network_policy_config {
      disabled = !var.enable_network_policy
    }
  }

  # --- ENCRIPTACION ---
  # Conecta con: etcd (base de datos de K8s). Protege los Secrets creados vía YAML.
  database_encryption {
    state = "ENCRYPTED"
    key_name = "" 
  }

  # --- OBSERVABILIDAD ---
  # Conecta con: Google Cloud Operations Suite (Logging y Monitoring).
  logging_service    = "logging.googleapis.com/kubernetes"
  monitoring_service = "monitoring.googleapis.com/kubernetes"

  # --- MANTENIMIENTO ---
  # Recibe del Main: var.release_channel.
  # Conecta con: Google para programar actualizaciones automáticas del sistema.
  release_channel {
    channel = var.release_channel
  }

  remove_default_node_pool = true # Obliga a Terraform a ignorar el pool básico ineficiente.
  initial_node_count       = 1
  deletion_protection      = true # Bloquea el borrado accidental del cluster.
}

# =============================================================================
# RECURSO: NODE POOL (LOS TRABAJADORES)
# =============================================================================
resource "google_container_node_pool" "nodes" {
  name     = "${var.cluster_name}-pool"
  location = var.region
  # Conecta con: El recurso 'google_container_cluster' creado arriba mediante su nombre.
  cluster  = google_container_cluster.cluster.name

  # --- ESCALABILIDAD ---
  # Recibe del Main: var.min_nodes y var.max_nodes.
  # Conecta con: Compute Engine Autoscaler para crear/borrar máquinas según la carga.
  autoscaling {
    min_node_count = var.min_nodes
    max_node_count = var.max_nodes
  }

  # --- MANTENIMIENTO ---
  # Conecta con: Health Checks de Google para detectar y reemplazar máquinas congeladas.
  management {
    auto_repair  = true
    auto_upgrade = true
  }

  # --- CONFIGURACION FISICA ---
  node_config {
    # Recibe del Main: var.machine_type y var.node_sa_email (vienen del módulo 'iam').
    # Conecta con: Instancias de Compute Engine y Service Accounts de IAM.
    machine_type    = var.machine_type
    disk_size_gb    = var.disk_size_gb
    disk_type       = var.disk_size_gb
    service_account = var.node_sa_email

    # Conecta con: El hardware de seguridad del servidor físico (Titan chip).
    shielded_instance_config {
      enable_secure_boot          = true
      enable_integrity_monitoring = true
    }

    # Conecta con: APIs de Google Cloud para que el nodo pueda operar.
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
    
    metadata = {
      disable-legacy-endpoints = "true"
    }
    
    # Conecta con: Módulo 'firewall'. Este tag activa las reglas de Master-to-Nodes y Health Checks.
    tags = ["gke-node"]
  }
}