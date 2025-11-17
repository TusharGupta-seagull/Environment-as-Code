# VPC Module
module "vpc" {
  source = "../_modules/network/vpc"

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
