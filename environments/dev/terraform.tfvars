project_id = "zafa-dev-zafa"
host_project_id = "zafa-host-zafa"
region = "europe-west1"
cluster_name = "gke-standard-kubernetes"

min_nodes = "1"
max_nodes = "2"
machine_type = "e2-medium"
disk_size_gb = 15

vpc_self_link = "https://www.googleapis.com/compute/v1/projects/zafa-host-zafa/global/networks/vpc-kubernetes"

subnet_standard_self_link  = "https://www.googleapis.com/compute/v1/projects/zafa-host-zafa/regions/europe-west1/subnetworks/subnet-gke-standard"