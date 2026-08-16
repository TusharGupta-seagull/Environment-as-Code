module "vpc" {
  source = "../_modules/network/vpc"

  name_prefix             = local.name_prefix
  vpc_cidr                = var.network_config.vpc.cidr
  pub_cidrs               = var.network_config.subnets.public
  priv_cidrs              = var.network_config.subnets.private
  map_public_ip_on_launch = var.network_config.settings.map_public_ip_on_launch
  nat_gateway_subnet_cidr = var.network_config.subnets.public[0].cidr
  cidr_all_traffic        = "0.0.0.0/0"
  tags                    = var.project_config.tags
}
