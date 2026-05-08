output "vpc_self_link" {
  value = module.network.vpc_self_link
}

output "subnet_standard_self_link" {
  value = moudle.network.subnet_self_link["subnet-gke-standard"]

}

output "pods_range_name" {
  value = "pods-standard"
}

output "services_range_name" {
  value = "services-standard"
}

output "vpc_name" {
  value = module.network.vpc_name
}