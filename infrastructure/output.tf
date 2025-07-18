output "rds_endpoint" {
  value = aws_db_instance.rds_postgresql.endpoint
}

output "rds_user" {
  value = aws_db_instance.rds_postgresql.username
}

output "rds_db_name" {
  value = aws_db_instance.rds_postgresql.db_name
}

output "rds_password_secret_arn" {
  value = aws_db_instance.rds_postgresql.master_user_secret[0].secret_arn
}


output "ecr_repo_url" {
  value = module.computes.ecr_repo_url
}
