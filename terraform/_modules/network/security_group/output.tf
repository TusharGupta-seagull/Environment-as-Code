output "security_group_id" {
  description = "ID of the security group"
  value       = var.create_sg ? aws_security_group.this[0].id : null
}

output "security_group_arn" {
  description = "ARN of the security group"
  value       = var.create_sg ? aws_security_group.this[0].arn : null
}

output "security_group_name" {
  description = "Name of the security group"
  value       = var.create_sg ? aws_security_group.this[0].name : null
}

output "security_group_vpc_id" {
  description = "VPC ID of the security group"
  value       = var.create_sg ? aws_security_group.this[0].vpc_id : null
}

output "security_group_owner_id" {
  description = "Owner ID of the security group"
  value       = var.create_sg ? aws_security_group.this[0].owner_id : null
}

output "ingress_rule_ids" {
  description = "IDs of the ingress rules"
  value       = var.create_sg ? { for k, v in aws_vpc_security_group_ingress_rule.this : k => v.id } : {}
}

output "egress_rule_ids" {
  description = "IDs of the egress rules"
  value       = var.create_sg ? { for k, v in aws_vpc_security_group_egress_rule.this : k => v.id } : {}
}
