# Root Module - output.tf

# VPC Outputs
output "vpc" {
  description = "VPC outputs"
  value = {
    id         = module.vpc.vpc_id
    cidr_block = module.vpc.vpc_cidr_block
    name       = module.vpc.vpc_name
  }

}

output "subnets" {
  description = "Subnet outputs"
  value = {
    public = {
      ids               = module.vpc.public_subnet_ids
      availability_zone = module.vpc.public_subnet_availability_zones
      cidr_blocks       = module.vpc.public_subnet_cidrs
    }
    private = {
      ids               = module.vpc.private_subnet_ids
      availability_zone = module.vpc.private_subnet_availability_zones
      cidr_blocks       = module.vpc.private_subnet_cidrs
    }
  }
}

output "network_gateways" {
  description = "Network gateway outputs"
  value = {
    internet_gateway_id   = module.vpc.internet_gateway_id
    nat_gateway_id        = module.vpc.nat_gateway_id
    nat_gateway_public_ip = module.vpc.nat_gateway_public_ip
  }
}

# Security Groups
output "security_groups" {
  description = "Security group outputs"
  value = {
    bastion = {
      id   = module.bastion_security_group.security_group_id
      name = module.bastion_security_group.security_group_name
    }
    app = {
      id   = module.app_security_group.security_group_id
      name = module.app_security_group.security_group_name
    }
    db = {
      id   = module.db_security_group.security_group_id
      name = module.db_security_group.security_group_name
    }
    alb = {
      id   = module.alb_security_group.security_group_id
      name = module.alb_security_group.security_group_name
    }
  }
}

# EC2 Instances
output "bastion_instances" {
  description = "Bastion host instance details"
  value = {
    for idx, instance in module.bastion_instances : idx => {
      id            = instance.id
      public_ip     = instance.public_ip
      private_ip    = instance.private_ip
      instance_type = instance.instance_type
      az            = instance.availability_zone
      state         = instance.instance_state
    }
  }
}

output "app_instances" {
  description = "Application instances details"
  value = {
    for idx, instance in module.app_instances : idx => {
      id            = instance.id
      private_ip    = instance.private_ip
      instance_type = instance.instance_type
      az            = instance.availability_zone
      state         = instance.instance_state
    }
  }
}

output "db_instances" {
  description = "Database instances details"
  value = {
    for idx, instance in module.db_instances : idx => {
      id            = instance.id
      private_ip    = instance.private_ip
      instance_type = instance.instance_type
      az            = instance.availability_zone
      state         = instance.instance_state
    }
  }
}

# Application Load Balancer
output "load_balancer" {
  description = "Application Load Balancer details"
  value = {
    enabled          = var.create_alb
    arn              = try(module.alb[0].lb_arn, null)
    dns_name         = try(module.alb[0].lb_dns_name, null)
    zone_id          = try(module.alb[0].lb_zone_id, null)
    arn_suffix       = try(module.alb[0].lb_arn_suffix, null)
    target_group_arn = try(module.alb.target_group_arn, null)
    url              = try("http://${module.alb[0].lb_dns_name}", null)
    https_url        = try(var.alb_config.certificate_arn != null ? "https://${module.alb[0].lb_dns_name}" : null, null)
  }
}

# Deployment Summary
output "deployment_summary" {
  description = "Comprehensive deployment summary"
  value = {
    project = {
      name        = var.project_name
      environment = var.env_name
      region      = var.aws_region
    }
    infrastructure = {
      vpc_id          = module.vpc.vpc_id
      public_subnets  = length(module.vpc.public_subnet_ids)
      private_subnets = length(module.vpc.private_subnet_ids)
      bastion_hosts   = length(module.bastion_instances)
      app_servers     = length(module.app_instances)
      db_servers      = length(module.db_instances)
      load_balancer   = var.create_alb ? "Enabled" : "Disabled"
    }
    connectivity = {
      bastion_public_ip = try(module.bastion_instances[0].public_ip, null)
      alb_dns_name      = try(module.alb.lb_dns_name, null)
    }
    security = {
      ssh_key_name     = aws_key_pair.ansible_key.key_name
      allowed_ssh_cidr = var.allowed_ssh_cidr
    }
  }
}

#Ansible output
output "ansible" {
  description = "Ansible configuration outputs"
  value = {
    inventory_file     = try(local_file.ansible_inventory.filename, null)
    ssh_config_file    = try(local_file.ssh_config.filename, null)
    ssh_key_path       = local.ssh_key_path
    bastion_connection = try("ssh -i ${local.ssh_key_path} ${var.ssh_user}@${module.bastion_instances[0].public_ip}", null)
  }
  sensitive = true
}
