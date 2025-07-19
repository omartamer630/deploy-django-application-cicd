variable "environment" {
  description = "The environment for the resources"
  type        = string
  default     = "dev"
}

variable "cidr_block" {
  description = "The CIDR block for the Network"
  type = list(object({
    name = string
    cidr = string
  }))
}

variable "az" {
  description = "The Availability Zone for the Subnet"
  type        = list(string)
}

variable "region" {
  description = "The Region that i will implement my Infra in AWS"
  default     = "us-east-1"
}

variable "container_port" {}
variable "cpu" {}
variable "memory" {}

variable "db_master_password" {
  description = "Master password for RDS"
  type        = string
  sensitive   = true
}
variable "image_name" {
  description = "Contains the image name"
  type = string
}
