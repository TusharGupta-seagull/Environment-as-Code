output "instance_id" {
  description = "The ID of the EC2 instance"
  value       = local.create_instance ? aws_instance.main[0].id : null
}

output "instance_arn" {
  description = "The ARN of the EC2 instance"
  value       = local.create_instance ? aws_instance.main[0].arn : null
}

output "instance_public_ip" {
  description = "The public IP address of the EC2 instance"
  value       = local.create_instance ? aws_instance.main[0].public_ip : null
}

output "instance_private_ip" {
  description = "The private IP address of the EC2 instance"
  value       = local.create_instance ? aws_instance.main[0].private_ip : null
}