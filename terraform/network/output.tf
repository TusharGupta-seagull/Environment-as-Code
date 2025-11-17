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