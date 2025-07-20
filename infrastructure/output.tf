output "rds_endpoint" {
  value = aws_db_instance.rds_postgresql.endpoint
}

output "ecr_repo_url" {
  value = module.computes.ecr_repo_url
}
