output "rds_endpoint" {
  value = aws_db_instance.rds_postgresql.endpoint
}

output "rds_user" {
  value = aws_db_instance.rds_postgresql.username
}

output "rds_db_name" {
  value = aws_db_instance.rds_postgresql.db_name
}

output "ecr_repo_url" {
  value = module.computes.ecr_repo_url
}
