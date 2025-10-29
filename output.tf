
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

output "ec2_security_group_id" {
  description = "ID of the EC2 security group"
  value       = module.ec2_security_group.security_group_id
}

output "alb_security_group_id" {
  description = "ID of the ALB security group"
  value       = var.create_alb ? module.alb_security_group.security_group_id : null
}

output "ec2_instance_ids" {
  description = "IDs of all EC2 instances"
  value       = [for instance in module.ec2_instances : instance.id]
}

output "ec2_instance_private_ips" {
  description = "Private IP addresses of EC2 instances"
  value       = [for instance in module.ec2_instances : instance.private_ip]
}

output "ec2_instance_public_ips" {
  description = "Public IP addresses of EC2 instances (if assigned)"
  value       = [for instance in module.ec2_instances : instance.public_ip]
}

output "ec2_instance_details" {
  description = "Detailed information about each EC2 instance"
  value = {
    for idx, instance in module.ec2_instances : idx => {
      id         = instance.id
      private_ip = instance.private_ip
      public_ip  = instance.public_ip
      subnet_id  = instance.subnet_id
      az         = instance.availability_zone
    }
  }
}

output "alb_arn" {
  description = "ARN of the Application Load Balancer"
  value       = var.create_alb ? module.alb[0].lb_arn : null
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = var.create_alb ? module.alb[0].lb_dns_name : null
}

output "alb_zone_id" {
  description = "Zone ID of the Application Load Balancer"
  value       = var.create_alb ? module.alb[0].lb_zone_id : null
}

output "alb_target_group_arn" {
  description = "ARN of the ALB target group"
  value       = var.create_alb ? module.alb[0].target_group_arn : null
}

output "alb_url" {
  description = "URL to access the Application Load Balancer"
  value       = var.create_alb ? "http://${module.alb[0].lb_dns_name}" : null
}

output "deployment_summary" {
  description = "Summary of the deployed infrastructure"
  value = {
    region             = var.aws_region
    project_name       = var.project_name
    environment        = var.environment
    vpc_id             = module.vpc.vpc_id
    instance_count     = var.instance_count
    load_balancer_type = var.create_alb ? "application" : "none"
  }
}