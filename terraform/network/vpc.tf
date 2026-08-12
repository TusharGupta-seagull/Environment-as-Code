locals {
  vpc = {
    cidr = var.network_config.vpc.cidr
  }
  subnets = {
    public  = var.network_config.subnets.public
    private = var.network_config.subnets.private
  }
  network_settings = {
    map_public_ip_on_launch = var.network_config.settings.map_public_ip_on_launch
    create_alb              = var.network_config.settings.create_alb
    allowed_ssh_cidr        = var.network_config.settings.allowed_ssh_cidr
  }

  nat_subnet_cidr  = var.network_config.subnets.public[0].cidr
  cidr_all_traffic = "0.0.0.0/0"
}

module "vpc" {
  source = "../_modules/network/vpc"

  name_prefix             = local.name_prefix
  vpc_cidr                = local.vpc.cidr
  pub_cidrs               = local.subnets.public
  priv_cidrs              = local.subnets.private
  map_public_ip_on_launch = local.network_settings.map_public_ip_on_launch
  nat_gateway_subnet_cidr = local.nat_subnet_cidr
  cidr_all_traffic        = local.cidr_all_traffic
  tags                    = local.project_config.tags
}
