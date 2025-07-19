# Networking - AWS VPC with public and private subnets
resource "aws_vpc" "main" {
  cidr_block           = var.cidr_block[0].cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.environment}-${var.cidr_block[0].name}"
  }
}

resource "aws_default_route_table" "default_rtb" {
  default_route_table_id = aws_vpc.main.default_route_table_id
  tags = {
    Name = "${var.environment}-default-rtb"
  }
}

module "subnet" {
  source          = "./modules/subnets"
  vpc_id          = aws_vpc.main.id
  vpc_cidr        = aws_vpc.main.cidr_block
  region          = var.region
  subnet_az       = var.az
  env             = var.environment
  vpc_endpoint_sg = aws_security_group.vpc_endpoints_sg.id
}


module "computes" {
  source                  = "./modules/computes"
  env                     = var.environment
  vpc_id                  = aws_vpc.main.id
  repo_name               =  var.image_name
  cluster_name            = "my-app-cluster"
  cluster_region          = var.region
  ecs_type                = "FARGATE"
  network_mode            = "awsvpc"
  memory_size             = var.memory
  cpu_size                = var.cpu
  desired_containers      = 3
  container_port          = var.container_port
  host_port               = var.container_port
  service_subnets         = [module.subnet.private_subnet_1.id, module.subnet.private_subnet_2.id]
  service_security_groups = [aws_security_group.ecs_sg.id]
  public_ip               = false
  alb_subnets             = [module.subnet.public_subnet_1.id, module.subnet.public_subnet_2.id]
  alb_security_groups     = [aws_security_group.ecs_sg.id, aws_security_group.alb_sg.id]
  alb_target_type         = "ip"
  db_name                 = aws_db_instance.rds_postgresql.db_name
  db_username             = aws_db_instance.rds_postgresql.username
  db_password             = aws_db_instance.rds_postgresql.password
  db_endpoint             = aws_db_instance.rds_postgresql.address
  db_port                 = aws_db_instance.rds_postgresql.port
  depends_on              = [aws_db_instance.rds_postgresql]
}

#################################

# Security - AWS SG


resource "aws_security_group" "vpc_endpoints_sg" {
  name_prefix = "${var.environment}-vpc-endpoints"
  description = "Associated to ECR/s3 VPC Endpoints"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "Allow Nodes to pull images from ECR via VPC endpoints"
    protocol        = "tcp"
    from_port       = 443
    to_port         = 443
    security_groups = [aws_security_group.ecs_sg.id]
  }
  ingress {
    protocol    = "tcp"
    from_port   = var.container_port
    to_port     = var.container_port
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "ecs_sg" {
  name_prefix = "${var.environment}-ecs-sg"
  description = "Associated to ECS"
  vpc_id      = aws_vpc.main.id

  ingress {
    protocol        = "tcp"
    from_port       = var.container_port
    to_port         = var.container_port
    security_groups = [aws_security_group.alb_sg.id]
  }
  ingress {
    protocol        = "tcp"
    from_port       = 443
    to_port         = 443
    security_groups = [aws_security_group.alb_sg.id]
  }
  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "alb_sg" {
  name_prefix = "${var.environment}-alb-sg"
  description = "Associated to alb"
  vpc_id      = aws_vpc.main.id

  ingress {
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]

  }
  ingress {
    protocol    = "tcp"
    from_port   = var.container_port
    to_port     = var.container_port
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# VPC 1 Security group
resource "aws_security_group" "vpc_1_security_group" {
  vpc_id = aws_vpc.main.id
  # Add RDS Postgres ingress rule
  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"] # Replace with a more restrictive CIDR if needed
    security_groups = [aws_security_group.ecs_sg.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "RDS_SG"
  }

}
#################################

# Database - AWS RDS

resource "aws_db_instance" "rds_postgresql" {
  db_name = "hello_db"
  identifier                  = "postgres-db"
  username                    = "hello_user"
  password                    = var.db_master_password
  allocated_storage           = 20
  storage_encrypted           = true
  engine                      = "postgres"
  engine_version              = "14"
  instance_class              = "db.t3.micro"
  apply_immediately           = true
  publicly_accessible         = false # default is false
  multi_az                    = true  # using stand alone DB
  skip_final_snapshot         = true  # after deleting RDS aws will not create snapshot 
  copy_tags_to_snapshot       = true  # default = false
  db_subnet_group_name        = aws_db_subnet_group.db_attach_subnet.id
  vpc_security_group_ids      = [aws_security_group.ecs_sg.id, aws_security_group.vpc_1_security_group.id]
  auto_minor_version_upgrade  = false # default = false
  allow_major_version_upgrade = true  # default = true
  backup_retention_period     = 0     # default value is 7
  delete_automated_backups    = true  # default = true

  tags = {
    Name = "${var.environment}-rds-posgress"
  }
}

resource "aws_db_subnet_group" "db_attach_subnet" {
  name = "db-subnet-group"
  subnet_ids = [
    "${module.subnet.private_subnet_1.id}",
    "${module.subnet.private_subnet_2.id}"
  ]
  tags = {
    Name = "${var.environment}-db-subnets"
  }
}
