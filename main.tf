# Root Module - main.tf

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = var.common_tags
  }
}

# VPC Module

module "vpc" {
  source = "./modules/network/vpc"

  project_name = var.project_name
  env_name     = var.environment
  vpc_cidr     = var.vpc_cidr

  pub_cidrs = var.public_subnets
  priv_cidrs = var.private_subnets

  nat_gateway_subnet_cidr = var.nat_gateway_subnet_cidr
  cidr_all_traffic        = "0.0.0.0/0"

  tags = var.common_tags
}

# Security Groups Module

## Security Group for EC2 Instances
module "ec2_security_group" {
  source = "./modules/network/security_group"

  create_sg      = true
  sg_name        = "${var.project_name}-${var.environment}-ec2-sg"
  sg_description = "Security group for EC2 instances"
  sg_vpc_id      = module.vpc.vpc_id

  sg_ingress_rules = {
    ssh = {
      from_port   = 22
      to_port     = 22
      ip_protocol = "tcp"
      cidr_ipv4   = var.allowed_ssh_cidr
      description = "Allow SSH access"
    }
    http = {
      from_port   = 80
      to_port     = 80
      ip_protocol = "tcp"
      cidr_ipv4   = "0.0.0.0/0"
      description = "Allow HTTP from anywhere"
    }
    https = {
      from_port   = 443
      to_port     = 443
      ip_protocol = "tcp"
      cidr_ipv4   = "0.0.0.0/0"
      description = "Allow HTTPS from anywhere"
    }
  }

  sg_egress_rules = {
    all_traffic = {
      from_port   = 0
      to_port     = 0
      ip_protocol = "-1"
      cidr_ipv4   = "0.0.0.0/0"
      description = "Allow all outbound traffic"
    }
  }

  tags = var.common_tags
  sg_tags = {
    Component = "compute"
  }
}

## Security Group for Application Load Balancer

module "alb_security_group" {
  source = "./modules/network/security_group"

  create_sg      = var.create_alb
  sg_name        = "${var.project_name}-${var.environment}-alb-sg"
  sg_description = "Security group for Application Load Balancer"
  sg_vpc_id      = module.vpc.vpc_id

  sg_ingress_rules = {
    http = {
      from_port   = 80
      to_port     = 80
      ip_protocol = "tcp"
      cidr_ipv4   = "0.0.0.0/0"
      description = "Allow HTTP from internet"
    }
    https = {
      from_port   = 443
      to_port     = 443
      ip_protocol = "tcp"
      cidr_ipv4   = "0.0.0.0/0"
      description = "Allow HTTPS from internet"
    }
  }

  sg_egress_rules = {
    all_traffic = {
      from_port   = 0
      to_port     = 0
      ip_protocol = "-1"
      cidr_ipv4   = "0.0.0.0/0"
      description = "Allow all outbound traffic"
    }
  }

  tags = var.common_tags
  sg_tags = {
    Component = "load-balancer"
  }
}

# EC2 Instances Module

module "ec2_instances" {
  source = "./modules/compute/ec2-instance"
  count  = var.instance_count

  create        = true
  name          = "${var.project_name}-${var.environment}-instance-${count.index + 1}"
  ami_id        = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name

  # Place instances in public subnets (rotate through available subnets)
  subnet_id         = module.vpc.public_subnet_ids[count.index % length(module.vpc.public_subnet_ids)]
  availability_zone = var.public_subnets[count.index % length(var.public_subnets)].avail_zone

  user_data = var.user_data_script

  root_block_device = {
    volume_type           = "gp3"
    volume_size           = var.root_volume_size
    delete_on_termination = true
    encrypted             = var.enable_encryption
  }

  tags = var.common_tags
  instance_tags = {
    Role        = "web-server"
    Environment = var.environment
  }

  depends_on = [module.vpc, module.ec2_security_group]
}

# Attach security group to EC2 instances
resource "aws_network_interface_sg_attachment" "ec2_sg_attachment" {
  count = var.instance_count

  security_group_id    = module.ec2_security_group.security_group_id
  network_interface_id = module.ec2_instances[count.index].primary_network_interface_id
}

# Application Load Balancer Module

module "alb" {
  source = "./modules/compute/elb"
  count  = var.create_alb ? 1 : 0

  name                       = "${var.project_name}-${var.environment}-alb"
  vpc_id                     = module.vpc.vpc_id
  subnets                    = module.vpc.public_subnet_ids
  security_groups            = [module.alb_security_group.security_group_id]
  load_balancer_type         = "application"
  internal                   = false
  enable_deletion_protection = var.enable_deletion_protection

  target_instance_ids = [for instance in module.ec2_instances : instance.id]
  target_port         = var.target_port
  target_type         = "instance"
  listener_port       = 80
  protocol            = "HTTP"
  health_check_path   = var.health_check_path
  certificate_arn     = var.certificate_arn

  tags = merge(var.common_tags, {
    Component = "load-balancer"
    Type      = "application"
  })

  depends_on = [module.vpc, module.ec2_instances, module.alb_security_group]
}