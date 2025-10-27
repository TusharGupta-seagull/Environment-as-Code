output "id" {
  description = "ID of the EC2 instance"
  value       = local.create_instance ? aws_instance.main[0].id : null
}

output "arn" {
  description = "ARN of the EC2 instance"
  value       = local.create_instance ? aws_instance.main[0].arn : null
}

output "instance_state" {
  description = "State of the EC2 instance"
  value       = local.create_instance ? aws_instance.main[0].instance_state : null
}

output "public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = local.create_instance ? aws_instance.main[0].public_ip : null
}

output "private_ip" {
  description = "Private IP address of the EC2 instance"
  value       = local.create_instance ? aws_instance.main[0].private_ip : null
}

output "public_dns" {
  description = "Public DNS name of the EC2 instance"
  value       = local.create_instance ? aws_instance.main[0].public_dns : null
}

output "private_dns" {
  description = "Private DNS name of the EC2 instance"
  value       = local.create_instance ? aws_instance.main[0].private_dns : null
}

output "subnet_id" {
  description = "Subnet ID where the instance is deployed"
  value       = local.create_instance ? aws_instance.main[0].subnet_id : null
}

output "availability_zone" {
  description = "Availability zone of the EC2 instance"
  value       = local.create_instance ? aws_instance.main[0].availability_zone : null
}

output "primary_network_interface_id" {
  description = "ID of the primary network interface"
  value       = local.create_instance ? aws_instance.main[0].primary_network_interface_id : null
}

output "ami" {
  description = "AMI ID used for the instance"
  value       = local.create_instance ? aws_instance.main[0].ami : null
}

output "instance_type" {
  description = "Instance type of the EC2 instance"
  value       = local.create_instance ? aws_instance.main[0].instance_type : null
}

output "key_name" {
  description = "Key pair name used for the instance"
  value       = local.create_instance ? aws_instance.main[0].key_name : null
}

output "tags_all" {
  description = "All tags assigned to the instance"
  value       = local.create_instance ? aws_instance.main[0].tags_all : null
}