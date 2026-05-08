variable "project_id" {
    type = string
}
 variable "host_project_id" {
    type = string
 }

 variable "region" {
    type = string
 }

 variable "vpc_self_link" {
    type = string
 }

 variable "subnet_standard_self_link" {
    type = string
 }

 variable "cluster_name" {
    type = string
 }

 variable "min_nodes" {
    type = number
 }

 variable "max_nodes" {
    type = number
 }

 variable "machine_type" {
    type = string
 }