
# VPC Outputs
output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "vpc_cidr" {
  description = "CIDR block of the VPC"
  value       = module.vpc.vpc_cidr_block
}

output "public_subnet_ids" {
  description = "IDs of public subnets"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs of private subnets"
  value       = module.vpc.private_subnet_ids
}

output "nat_gateway_id" {
  description = "ID of the NAT Gateway (if created)"
  value       = module.vpc.nat_gateway_id
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = module.vpc.internet_gateway_id
}

# Security Groups
output "bastion_security_group_id" {
  description = "ID of Bastion SG"
  value       = module.bastion_security_group.security_group_id
}

output "app_security_group_id" {
  description = "ID of App SG"
  value       = module.app_security_group.security_group_id
}

output "db_security_group_id" {
  description = "ID of DB SG"
  value       = module.db_security_group.security_group_id
}

output "alb_security_group_id" {
  description = "ID of ALB SG"
  value       = module.alb_security_group.security_group_id
}

# EC2 Instances
output "bastion_instance_ids" {
  description = "IDs of Bastion instances"
  value       = [for instance in module.bastion_instances : instance.id]
}

output "bastion_public_ips" {
  description = "Public IPs of Bastion instances"
  value       = [for instance in module.bastion_instances : instance.public_ip]
}

output "app_instance_ids" {
  description = "IDs of Application instances"
  value       = [for instance in module.app_instances : instance.id]
}

output "app_private_ips" {
  description = "Private IPs of Application instances"
  value       = [for instance in module.app_instances : instance.private_ip]
}

output "db_instance_ids" {
  description = "IDs of Database instances"
  value       = [for instance in module.db_instances : instance.id]
}

output "db_private_ips" {
  description = "Private IPs of Database instances"
  value       = [for instance in module.db_instances : instance.private_ip]
}

# Application Load Balancer
output "alb_arn" {
  description = "ARN of the Application Load Balancer"
  value       = module.alb.lb_arn
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = module.alb.lb_dns_name
}

output "alb_zone_id" {
  description = "Zone ID of the Application Load Balancer"
  value       = module.alb.lb_zone_id
}

output "alb_target_group_arn" {
  description = "ARN of the ALB target group"
  value       = module.alb.target_group_arn
}

output "alb_url" {
  description = "URL to access the Application Load Balancer"
  value       = "http://${module.alb.lb_dns_name}"
}

# Deployment Summary
output "deployment_summary" {
  description = "Summary of the deployed infrastructure"
  value = {
    region            = var.aws_region
    project_name      = var.project_name
    environment       = var.env_name
    vpc_id            = module.vpc.vpc_id
    bastion_instances = [for i in module.bastion_instances : i.id]
    app_instances     = [for i in module.app_instances : i.id]
    db_instances      = [for i in module.db_instances : i.id]
    alb_dns_name      = module.alb.lb_dns_name
  }
}
