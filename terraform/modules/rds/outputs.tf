output "rds_endpoint" {
  description = "RDS endpoint"
  value       = aws_db_instance.mysql.address
}

output "rds_port" {
  description = "Port"
  value       = aws_db_instance.mysql.port
}

output "rds_identifier" {
  description = "Identifier"
  value       = aws_db_instance.mysql.id
}

output "rds_arn" {
  description = "DB ARN"
  value       = aws_db_instance.mysql.arn
}

output "rds_sg_id" {
  description = "RDS SG ID"
  value       = aws_security_group.rds.id
}
