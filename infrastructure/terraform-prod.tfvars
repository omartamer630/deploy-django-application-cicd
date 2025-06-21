# Network CIDR blocks for the production environment
environment = "prod"
cidr_block = [
  {
    name = "vpc"
    cidr = "10.0.0.0/16"
  }
]
az = ["us-east-1a", "us-east-1b"]

container_port = 80
cpu            = 1024
memory         = 2048
