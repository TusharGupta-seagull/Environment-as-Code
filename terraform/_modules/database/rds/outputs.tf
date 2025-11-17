# Basic Connection Info
output "rds_endpoint" {
  description = "RDS endpoint (connection endpoint)"
  value       = aws_db_instance.this.address
  sensitive   = true
}

output "rds_hostname" {
  description = "RDS instance hostname"
  value       = aws_db_instance.this.address
  sensitive   = true
}

output "rds_port" {
  description = "RDS instance port"
  value       = aws_db_instance.this.port
  sensitive   = true
}

output "rds_username" {
  description = "RDS master username"
  value       = aws_db_instance.this.username
  sensitive   = true
}
output "rds_db_name" {
  description = "Initial database name"
  value       = aws_db_instance.this.db_name
}

# Engine Info
output "rds_engine" {
  description = "Engine used by the RDS instance"
  value       = aws_db_instance.this.engine
}

output "rds_engine_version" {
  description = "Engine version used by the RDS instance"
  value       = aws_db_instance.this.engine_version
}

# Instance Info

output "rds_instance_class" {
  description = "EC2 instance class for RDS"
  value       = aws_db_instance.this.instance_class
}

output "rds_allocated_storage" {
  description = "Allocated initial storage in GB"
  value       = aws_db_instance.this.allocated_storage
}

output "rds_max_allocated_storage" {
  description = "Max allocated storage with autoscaling"
  value       = aws_db_instance.this.max_allocated_storage
}

# Networking

output "rds_subnet_group" {
  description = "RDS subnet group name"
  value       = aws_db_instance.this.db_subnet_group_name
}

output "rds_security_groups" {
  description = "RDS attached security groups"
  value       = aws_db_instance.this.vpc_security_group_ids
}

output "rds_availability_zone" {
  description = "RDS primary availability zone"
  value       = aws_db_instance.this.availability_zone
}

# Metadata
output "rds_arn" {
  description = "Amazon Resource Name (ARN) of RDS"
  value       = aws_db_instance.this.arn
}

output "rds_status" {
  description = "Current RDS instance status"
  value       = aws_db_instance.this.status
}
