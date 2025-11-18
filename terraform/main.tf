# SSH KEY GENERATION
locals {
  project_config = var.project_config
  network_config = var.network_config
  ec2_config     = var.ec2_config
  alb_config     = var.alb_config
}
resource "tls_private_key" "ssh_key_gen" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "private_key_pem" {
  filename        = "${path.module}/ansible/${var.ec2_config.key_name}.pem"
  content         = tls_private_key.ssh_key_gen.private_key_pem
  file_permission = "0400"
}

resource "aws_key_pair" "ansible_key" {
  key_name   = var.ec2_config.key_name
  public_key = tls_private_key.ssh_key_gen.public_key_openssh
}

# NETWORK -> VPC, SUBNETS, SECURITY_GROUP, ROUTE53
module "network" {
  source         = "./network"
  project_config = local.project_config
  network_config = local.network_config
}

# Application Instances -> APP, DB, BASTION, LB
module "application_instances" {
  source = "./application"

  project_config = var.project_config
  ec2_config     = local.ec2_config
  alb_config     = local.alb_config
  ec2_network_config = {
    bastion = {
      subnet_id = module.network.subnets.public.ids[0]
      sg_ids    = [module.network.security_groups.bastion.id]
    }

    app = {
      subnet_id = module.network.subnets.private.ids[0]
      sg_ids    = [module.network.security_groups.app.id]
    }

    db = {
      subnet_id = module.network.subnets.private.ids[0]
      sg_ids    = [module.network.security_groups.db.id]
    }
  }

  alb_network_config = {
    vpc_id          = module.network.vpc.id
    subnets         = module.network.subnets.public.ids
    security_groups = [module.network.security_groups.alb.id]
  }

  depends_on = [module.network, aws_key_pair.ansible_key]
}

module "ansible-config" {
  source = "./config-mgmt"
  application_instance_ips = {
    app_private_ips   = [for ins in module.application_instances.app_instances : ins.private_ip]
    db_private_ips    = [for ins in module.application_instances.db_instances : ins.private_ip]
    bastion_public_ip = module.application_instances.bastion_instances[0].public_ip
  }
  depends_on = [
    module.application_instances
  ]
}

