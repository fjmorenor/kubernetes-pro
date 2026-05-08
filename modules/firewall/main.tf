# =============================================================================
# MÓDULO: FIREWALL - REGLAS DE SEGURIDAD PARA KUBERNETES
# =============================================================================
# Este archivo define los permisos de red. Sin estas reglas, los componentes 
# de GKE (Nodos, Master y Balanceadores) estarían aislados y el cluster no funcionaría.

# -----------------------------------------------------------------------------
# 1. REGLA: TRÁFICO INTERNO (VPC INTERNAL)
# -----------------------------------------------------------------------------
resource "google_compute_firewall" "allow_internal" {
  # Recibe del Main: var.project_id y var.vpc_name (nombre de la red creada).
  # Conecta con: Todos los recursos (Pods, VMs, DBs) que vivan dentro de la misma VPC.
  project = var.project_id
  name    = "${var.vpc_name}-allow-internal"
  network = var.vpc_name

  # QUE HACE: Permite la comunicación libre dentro del rango privado. 
  # Es vital para que un Pod pueda consultar a otro Pod o a una base de datos interna.
  allow {
    protocol = "tcp"  # Comunicación de aplicaciones.
 
  }

  allow {
    protocol = "udp"
  }

  allow {
    protocol = "icmp"
  }

  # Origen: Solo permite tráfico que nazca dentro del rango 10.x.x.x (Red privada).
  source_ranges = ["10.0.0.0/8"]
}

# -----------------------------------------------------------------------------
# 2. REGLA: HEALTH CHECKS DE GOOGLE CLOUD
# -----------------------------------------------------------------------------
resource "google_compute_firewall" "allow_health_checks" {
  # Recibe del Main: var.enable_health_checks (Booleano para activar/desactivar).
  # Conecta con: Los Balanceadores de Carga de Google Cloud.
  count = var.enable_health_checks ? 1 : 0

  project = var.project_id
  name    = "${var.vpc_name}-allow-health-checks"
  network = var.vpc_name

  # QUE HACE: Abre los puertos necesarios para que Google verifique si tus Apps están vivas.
  # Si esta regla falla, el Balanceador de Carga marcará tus nodos como "UNHEALTHY".
  allow {
    protocol = "tcp"
    ports    = ["10256", "8080", "443"] 
  }

  # Origen: Rangos oficiales e inmutables de los sistemas de Google Cloud.
  source_ranges = ["35.191.0.0/16", "130.211.0.0/22"]

  # Destino: Se conecta específicamente con los nodos que tengan la etiqueta "gke-node" 
  # definida en el módulo gke-standard.
  target_tags   = ["gke-node"]
}

# -----------------------------------------------------------------------------
# 3. REGLA: MASTER -> NODOS (CONTROL PLANE COMMUNICATION)
# -----------------------------------------------------------------------------
resource "google_compute_firewall" "allow_master_to_nodes" {
  # Recibe del Main: var.enable_master_to_nodes y var.master_ipv4_cidr.
  # Conecta con: El "Cerebro" (Control Plane) de GKE gestionado por Google.
  count = var.enable_master_to_nodes ? 1 : 0

  project = var.project_id
  name    = "${var.vpc_name}-allow-master-to-nodes"
  network = var.vpc_name

  # QUE HACE: Permite que el Master envíe comandos a los nodos. 
  # Sin esto, no funcionan: 'kubectl logs', 'kubectl exec' ni la captura de métricas.
  allow {
    protocol = "tcp"
    ports    = ["443", "10250"] # 443 para API y 10250 para el agente Kubelet.
  }

  # Origen: El rango de IP privado del Master (definido en el módulo GKE).
  source_ranges = [var.master_ipv4_cidr]

  # Destino: Aplica a los nodos marcados con el tag "gke-node".
  target_tags   = ["gke-node"]
}