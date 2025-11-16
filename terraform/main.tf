# Root Module - main.tf

locals {
  ec2_config = {
    bastion = {
      count                       = 1
      instance_type               = "t3.micro"
      subnet_id                   = module.vpc.public_subnet_ids[0]
      key_name                    = aws_key_pair.ansible_key.key_name
      sg_ids                      = [module.bastion_security_group.security_group_id]
      ami_id                      = "ami-0ecb62995f68bb549"
      associate_public_ip_address = true
      root_block_device = {
        delete_on_termination = true
        volume_type           = "gp3"
        volume_size           = 10
        encrypted             = true
      }
    }

    app = {
      count                       = 2
      instance_type               = "t3.small"
      subnet_id                   = module.vpc.private_subnet_ids
      key_name                    = aws_key_pair.ansible_key.key_name
      sg_ids                      = [module.app_security_group.security_group_id]
      associate_public_ip_address = false
      root_block_device = {
        delete_on_termination = true
        volume_type           = "gp3"
        volume_size           = 10
        encrypted             = true
      }
    }

    db = {
      count                       = 1
      instance_type               = "t3.small"
      subnet_id                   = module.vpc.private_subnet_ids[0]
      key_name                    = aws_key_pair.ansible_key.key_name
      sg_ids                      = [module.db_security_group.security_group_id]
      associate_public_ip_address = false
      root_block_device = {
        delete_on_termination = true
        volume_type           = "gp3"
        volume_size           = 10
        encrypted             = true
      }
    }
  }
}

# SSH KEY GENERATION
resource "tls_private_key" "ssh_key_gen" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "private_key_pem" {
  filename        = "${path.module}/ansible/${var.key_name}.pem"
  content         = tls_private_key.ssh_key_gen.private_key_pem
  file_permission = "0400"
}

resource "aws_key_pair" "ansible_key" {
  key_name   = var.key_name
  public_key = tls_private_key.ssh_key_gen.public_key_openssh
}


# VPC Module
module "vpc" {
  source = "./modules/network/vpc"

  project_name = var.project_name
  env_name     = var.env_name
  vpc_cidr     = var.vpc_cidr

  pub_cidrs               = var.public_subnets
  priv_cidrs              = var.private_subnets
  map_public_ip_on_launch = var.map_public_ip_on_launch

  nat_gateway_subnet_cidr = var.public_subnets[0].cidr
  cidr_all_traffic        = "0.0.0.0/0"

  tags = var.tags
}

# Security Groups Module

## Security Group for Application Load Balancer
module "alb_security_group" {
  source = "./modules/network/security_group"

  project_name   = var.project_name
  env_name       = var.env_name
  create_sg      = var.create_alb
  sg_name        = "${var.project_name}-${var.env_name}-alb-sg"
  sg_description = "Security group for Application Load Balancer"
  sg_vpc_id      = module.vpc.vpc_id

  sg_ingress_rules = {
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
      from_port   = -1
      to_port     = -1
      ip_protocol = "-1"
      cidr_ipv4   = "0.0.0.0/0"
      description = "Allow all outbound traffic"
    }
  }

  tags = var.tags
  sg_tags = {
    Component = "load-balancer"
  }
}

## Security Group for Bastion Host
module "bastion_security_group" {
  source = "./modules/network/security_group"

  project_name   = var.project_name
  env_name       = var.env_name
  create_sg      = true
  sg_name        = "${var.project_name}-${var.env_name}-bastion-sg"
  sg_description = "Security group for Bastion Host"
  sg_vpc_id      = module.vpc.vpc_id

  sg_ingress_rules = {
    ssh = {
      from_port   = 22
      to_port     = 22
      ip_protocol = "tcp"
      cidr_ipv4   = var.allowed_ssh_cidr
      description = "Allow SSH access from anywhere"
    }
  }

  sg_egress_rules = {
    all_traffic = {
      from_port   = -1
      to_port     = -1
      ip_protocol = "-1"
      cidr_ipv4   = "0.0.0.0/0"
      description = "Allow all outbound traffic"
    }
  }

  tags = var.tags
  sg_tags = {
    Component = "bastion-host"
  }
}


## Security Group for App Instances
module "app_security_group" {
  source = "./modules/network/security_group"

  project_name   = var.project_name
  env_name       = var.env_name
  create_sg      = true
  sg_name        = "${var.project_name}-${var.env_name}-app-sg"
  sg_description = "Security group for Application instances"
  sg_vpc_id      = module.vpc.vpc_id

  sg_ingress_rules = {
    ssh = {
      from_port                    = 22
      to_port                      = 22
      ip_protocol                  = "tcp"
      referenced_security_group_id = module.bastion_security_group.security_group_id
      description                  = "Allow SSH access from Bastion Host"
    }
    http = {
      from_port                    = 80
      to_port                      = 80
      ip_protocol                  = "tcp"
      referenced_security_group_id = module.alb_security_group.security_group_id
      description                  = "Allow HTTP from ALB"
    }
    https = {
      from_port                    = 443
      to_port                      = 443
      ip_protocol                  = "tcp"
      referenced_security_group_id = module.alb_security_group.security_group_id
      description                  = "Allow HTTPS from ALB"
    }
  }

  sg_egress_rules = {
    all_traffic = {

      from_port   = -1
      to_port     = -1
      ip_protocol = "-1"
      cidr_ipv4   = "0.0.0.0/0"
      description = "Allow all outbound traffic"
    }
  }

  tags = var.tags
  sg_tags = {
    Component = "app-servers"
  }
}

module "db_security_group" {
  source = "./modules/network/security_group"

  project_name   = var.project_name
  env_name       = var.env_name
  create_sg      = true
  sg_name        = "${var.project_name}-${var.env_name}-db-sg"
  sg_description = "Security group for Database instances"
  sg_vpc_id      = module.vpc.vpc_id

  sg_ingress_rules = {
    ssh = {
      from_port                    = 22
      to_port                      = 22
      ip_protocol                  = "tcp"
      referenced_security_group_id = module.bastion_security_group.security_group_id
      description                  = "Allow SSH access from Bastion Host"
    }
    db = {
      from_port                    = 3306
      to_port                      = 3306
      ip_protocol                  = "tcp"
      referenced_security_group_id = module.app_security_group.security_group_id
      description                  = "Allow DB access from App SG"
    }
  }

  sg_egress_rules = {
    all_traffic = {
      from_port   = -1
      to_port     = -1
      ip_protocol = "-1"
      cidr_ipv4   = "0.0.0.0/0"
      description = "Allow all outbound traffic"
    }
  }

  tags = var.tags
  sg_tags = {
    Component = "db-servers"
  }
}


# EC2 Instances Module

## instance for bastion host
module "bastion_instances" {
  source = "./modules/compute/ec2-instance"
  count  = local.ec2_config["bastion"].count

  create = true
  name   = "${var.project_name}-${var.env_name}-bastion-host"

  instance_type               = local.ec2_config["bastion"].instance_type
  subnet_id                   = local.ec2_config["bastion"].subnet_id
  key_name                    = local.ec2_config["bastion"].key_name
  vpc_security_group_ids      = local.ec2_config["bastion"].sg_ids
  associate_public_ip_address = lookup(local.ec2_config["bastion"], "associate_public_ip_address", true)
  ami_id                      = lookup(local.ec2_config["bastion"], "ami_id", null)
  user_data                   = lookup(local.ec2_config["bastion"], "user_data", null)
  availability_zone           = lookup(local.ec2_config["bastion"], "availability_zone", null)
  root_block_device           = lookup(local.ec2_config["bastion"], "root_block_device", null)

  tags = var.tags
  instance_tags = {
    Role        = "jump-server"
    Environment = var.env_name
  }

  depends_on = [module.vpc, module.bastion_security_group, aws_key_pair.ansible_key]
}

## instance for application
module "app_instances" {
  source = "./modules/compute/ec2-instance"
  count  = local.ec2_config["app"].count

  create = true
  name   = "${var.project_name}-${var.env_name}-app-${count.index + 1}"

  instance_type               = local.ec2_config["app"].instance_type
  subnet_id                   = local.ec2_config["app"].subnet_id[count.index % length(local.ec2_config["app"].subnet_id)]
  key_name                    = local.ec2_config["app"].key_name
  vpc_security_group_ids      = local.ec2_config["app"].sg_ids
  associate_public_ip_address = lookup(local.ec2_config["app"], "associate_public_ip_address", false)
  ami_id                      = lookup(local.ec2_config["app"], "ami_id", null)
  user_data                   = lookup(local.ec2_config["app"], "user_data", null)
  availability_zone           = lookup(local.ec2_config["app"], "availability_zone", null)
  root_block_device           = lookup(local.ec2_config["app"], "root_block_device", null)

  tags = var.tags
  instance_tags = {
    Role        = "app-server"
    Environment = var.env_name
  }

  depends_on = [module.vpc, module.app_security_group, aws_key_pair.ansible_key]
}

## instance for database
module "db_instances" {
  source = "./modules/compute/ec2-instance"
  count  = local.ec2_config["db"].count

  create = true
  name   = "${var.project_name}-${var.env_name}-db-${count.index + 1}"

  instance_type               = local.ec2_config["db"].instance_type
  subnet_id                   = local.ec2_config["db"].subnet_id
  key_name                    = local.ec2_config["db"].key_name
  vpc_security_group_ids      = local.ec2_config["db"].sg_ids
  associate_public_ip_address = lookup(local.ec2_config["db"], "associate_public_ip_address", false)
  ami_id                      = lookup(local.ec2_config["db"], "ami_id", null)
  availability_zone           = lookup(local.ec2_config["db"], "availability_zone", null)
  root_block_device           = lookup(local.ec2_config["db"], "root_block_device", null)

  tags = var.tags
  instance_tags = {
    Role        = "db-server"
    Environment = var.env_name
  }

  depends_on = [module.vpc, module.db_security_group, aws_key_pair.ansible_key]
}

# Application Load Balancer
module "alb" {
  source = "./modules/compute/elb"
  count  = var.create_alb ? 1 : 0

  name                       = "${var.project_name}-${var.env_name}-alb"
  vpc_id                     = module.vpc.vpc_id
  subnets                    = module.vpc.public_subnet_ids
  security_groups            = [module.alb_security_group.security_group_id]
  load_balancer_type         = var.alb_config.load_balancer_type
  internal                   = var.alb_config.internal
  enable_deletion_protection = var.alb_config.enable_deletion_protection

  target_instance_ids = [for instance in module.app_instances[*] : instance.id]
  target_port         = var.alb_config.target_port
  target_type         = var.alb_config.target_type
  listener_port       = var.alb_config.listener_port
  protocol            = var.alb_config.protocol
  health_check_path   = var.alb_config.health_check_path
  certificate_arn     = var.alb_config.certificate_arn

  tags = merge(var.tags, {
    "Component" = "load-balancer"
    "Type"      = "application"
  })

  depends_on = [module.vpc, module.app_instances, module.alb_security_group]
}

