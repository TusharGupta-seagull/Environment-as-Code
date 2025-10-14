output "security_group_id" {
  description = "The ID of the created or existing security group"
  value       = local.create_sg ? aws_security_group.main[0].id : null
}

output "security_group_arn" {
  description = "The ARN of the created or existing security group"
  value       = local.create_sg ? aws_security_group.main[0].arn : null
}

output "security_group_name" {
  description = "The name of the security group"
  value       = local.create_sg ? aws_security_group.main[0].name : var.sg_name
}
