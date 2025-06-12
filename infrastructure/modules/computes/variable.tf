variable "repo_name" {}
variable "cluster_name" {}
variable "network_mode" {}
variable "cluster_region" {}
variable "ecs_type" {}
variable "memory_size" {}
variable "cpu_size" {}
variable "container_port" {}
variable "host_port" {}
variable "env" {}
variable "desired_containers" {}
variable "public_ip" {}
variable "vpc_id" {}
variable "service_subnets" {
  type = list(string)
}
variable "service_security_groups" {
  type = list(string)
}



variable "alb_target_type" {}
variable "alb_subnets" {
  type = list(string)
}
variable "alb_security_groups" {
  type = list(string)
}
