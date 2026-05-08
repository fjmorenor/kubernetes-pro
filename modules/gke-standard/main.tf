# =============================================================================
# RECURSO: CLUSTER DE KUBERNETES (CONTROL PLANE)
# =============================================================================
resource "google_container_cluster" "cluster" {
  provider = google-beta

  name     = var.cluster_name
  location = var.region

  # --- NETWORKING ---
  network    = var.vpc_self_link
  subnetwork = var.subnet_self_link

  networking_mode = "VPC_NATIVE"
  ip_allocation_policy {
    cluster_secondary_range_name  = var.pods_range_name
    services_secondary_range_name = var.services_range_name
  }

  # --- PRIVACIDAD ---
  private_cluster_config {
    enable_private_nodes    = var.enable_private_nodes
    enable_private_endpoint = var.enable_private_endpoint
    master_ipv4_cidr_block  = "172.16.0.0/28"
  }

  # --- SEGURIDAD: REDES AUTORIZADAS (REQUERIDO PARA ENDPOINT PRIVADO) ---
  master_authorized_networks_config {
    gcp_public_cidrs_access_enabled = false

    cidr_blocks {
      # Permite que la red interna (nodos, pods y servicios) acceda al API Server
      cidr_block   = "10.0.0.0/8" 
      display_name = "internal-vpc-access"
    }
  }

  # --- WORKLOAD IDENTITY ---
  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  # --- ADDONS ---
  addons_config {
    network_policy_config {
      disabled = !var.enable_network_policy
    }
  }

  # --- ENCRIPTACION ---
  # Cambiado a DECRYPTED ya que state = "ENCRYPTED" requiere un key_name válido de Cloud KMS.
  database_encryption {
    state = "DECRYPTED"
  }

  # --- OBSERVABILIDAD ---
  logging_service    = "logging.googleapis.com/kubernetes"
  monitoring_service = "monitoring.googleapis.com/kubernetes"

  # --- MANTENIMIENTO ---
  release_channel {
    channel = var.release_channel
  }

  remove_default_node_pool = true
  initial_node_count       = 1
  
  # Recomendado en false durante desarrollo para evitar bloqueos al destruir/recrear
  deletion_protection      = false 
}

# =============================================================================
# RECURSO: NODE POOL (LOS TRABAJADORES)
# =============================================================================
resource "google_container_node_pool" "nodes" {
  name     = "${var.cluster_name}-pool"
  location = var.region
  cluster  = google_container_cluster.cluster.name

  # --- ESCALABILIDAD ---
  autoscaling {
    min_node_count = var.min_nodes
    max_node_count = var.max_nodes
  }

  # --- MANTENIMIENTO ---
  management {
    auto_repair  = true
    auto_upgrade = true
  }

  # --- CONFIGURACION FISICA ---
  node_config {
    machine_type    = var.machine_type
    disk_size_gb    = var.disk_size_gb
    disk_type       = "pd-standard" # Asegúrate de que este valor sea válido (pd-balanced o pd-standard)
    service_account = var.node_sa_email

    shielded_instance_config {
      enable_secure_boot          = true
      enable_integrity_monitoring = true
    }

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
    
    metadata = {
      disable-legacy-endpoints = "true"
    }
    
    tags = ["gke-node"]
  }
}