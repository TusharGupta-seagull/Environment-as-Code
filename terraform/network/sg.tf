locals {
  create_alb       = var.network_config.settings.create_alb
  allowed_ssh_cidr = var.network_config.settings.allowed_ssh_cidr
}

## Security Group for Application Load Balancer
module "alb_security_group" {
  source = "../_modules/network/security_group"

  name_prefix    = local.name_prefix
  create_sg      = local.create_alb
  sg_name        = "${local.name_prefix}-alb-sg"
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

  tags = local.project_config.tags
  sg_tags = {
    Component = "load-balancer"
  }
}

## Security Group for Bastion Host
module "bastion_security_group" {
  source = "../_modules/network/security_group"

  name_prefix = local.name_prefix

  create_sg      = true
  sg_name        = "${local.name_prefix}-bastion-sg"
  sg_description = "Security group for Bastion Host"
  sg_vpc_id      = module.vpc.vpc_id

  sg_ingress_rules = {
    ssh = {
      from_port   = 22
      to_port     = 22
      ip_protocol = "tcp"
      cidr_ipv4   = local.allowed_ssh_cidr
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

  tags = local.project_config.tags
  sg_tags = {
    Component = "bastion-host"
  }
}


## Security Group for App Instances
module "app_security_group" {
  source = "../_modules/network/security_group"

  name_prefix    = local.name_prefix
  create_sg      = true
  sg_name        = "${local.name_prefix}-app-sg"
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

  tags = local.project_config.tags
  sg_tags = {
    Component = "app-servers"
  }
}

# Security group for Database instances
module "db_security_group" {
  source = "../_modules/network/security_group"

  name_prefix    = local.name_prefix
  create_sg      = true
  sg_name        = "${local.name_prefix}-db-sg"
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

  tags = local.project_config.tags
  sg_tags = {
    Component = "db-servers"
  }
}

# Security group for RDS instance
module "rds_security_group" {
  source = "../_modules/network/security_group"

  name_prefix    = local.name_prefix
  create_sg      = true
  sg_name        = "${local.name_prefix}-rds-sg"
  sg_description = "Security group for RDS instance"
  sg_vpc_id      = module.vpc.vpc_id

  sg_ingress_rules = {
    db_bastion = {
      from_port                    = 3306
      to_port                      = 3306
      ip_protocol                  = "tcp"
      referenced_security_group_id = module.bastion_security_group.security_group_id
      description                  = "Allow SQL CLI access from Bastion Host"
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

  tags = local.project_config.tags
  sg_tags = {
    Component = "db-servers"
  }
}
