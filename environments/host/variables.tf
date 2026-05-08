variable "project_id" {
    type = string
}

variable "dev_project_id" {
    type = string
}

variable "region" {
    type = string
}

variable "vpc_name" {
    type = string
}

variable "subnet_primary_cidr" {
    type = string
    
}

variable "subnet_pods_name" {
    type = string
}


variable "subnet_pods_cidr" {
    type = string
    
}

variable "subnet_services_cidr" {
    type = string
    
}

variable "subnet_services_name" {
    type = string
}