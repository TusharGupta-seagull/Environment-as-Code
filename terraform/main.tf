locals {
  use_generated_key = var.ssh_key_pair_name == null
  ssh_key_name      = var.ssh_key_pair_name != null ? var.ssh_key_pair_name : var.ec2_config.key_name

  db_password_effective = (
    var.db_password != null ? var.db_password :
    var.db_password_ssm_parameter != null ? "" :
    (var.rds_config.create_rds ? try(random_password.db_password[0].result, "") : "")
  )
}

resource "tls_private_key" "ssh_key_gen" {
  count     = local.use_generated_key ? 1 : 0
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "private_key_pem" {
  count           = local.use_generated_key ? 1 : 0
  filename        = "${path.module}/../ansible/${local.ssh_key_name}.pem"
  content         = tls_private_key.ssh_key_gen[0].private_key_pem
  file_permission = "0400"
}

resource "aws_key_pair" "ansible_key" {
  count      = local.use_generated_key ? 1 : 0
  key_name   = local.ssh_key_name
  public_key = tls_private_key.ssh_key_gen[0].public_key_openssh
  tags       = var.project_config.tags
}

data "aws_key_pair" "existing" {
  count    = local.use_generated_key ? 0 : 1
  key_name = var.ssh_key_pair_name
}

# RDS password - generated and stored in SSM Parameter Store (SecureString)
resource "random_password" "db_password" {
  count   = var.rds_config.create_rds && var.db_password == null && var.db_password_ssm_parameter == null ? 1 : 0
  length  = 24
  special = false
}

resource "aws_ssm_parameter" "db_password" {
  count = var.rds_config.create_rds && var.db_password == null && var.db_password_ssm_parameter == null ? 1 : 0

  name  = "/${var.project_config.project_name}/${var.project_config.env_name}/db/password"
  type  = "SecureString"
  value = random_password.db_password[0].result
  tags  = var.project_config.tags
}

# NETWORK -> VPC, SUBNETS, SECURITY_GROUP, ROUTE53
module "network" {
  source         = "./network"
  project_config = var.project_config
  network_config = var.network_config
}

# Application Instances -> BASTION (EC2) + ASG services
module "application" {
  source = "./application"

  project_config = var.project_config
  ec2_config     = merge(var.ec2_config, { key_name = local.ssh_key_name })
  alb_config     = var.alb_config
  services       = var.services

  default_ami_id_ssm_parameter = var.default_ami_id_ssm_parameter

  ec2_network_config = {
    bastion = {
      subnet_id = module.network.subnets.public.ids[0]
      sg_ids    = [module.network.security_groups.bastion.id]
    }

    app = {
      subnet_ids = module.network.subnets.private.ids
      sg_ids     = [module.network.security_groups.app.id]
    }
  }

  alb_network_config = {
    vpc_id          = module.network.vpc.id
    subnets         = module.network.subnets.public.ids
    security_groups = [module.network.security_groups.alb.id]
  }

  depends_on = [module.network, aws_key_pair.ansible_key]
}

# RDS Instance DB
module "database" {
  source         = "./database"
  project_config = var.project_config
  rds_config = merge(var.rds_config, {
    credentials = {
      username               = var.rds_config.credentials.username
      password               = local.db_password_effective
      password_ssm_parameter = var.db_password_ssm_parameter
    }
  })
  rds_network_config = {
    security_group_ids = [module.network.security_groups.rds.id]
    subnet_ids         = module.network.subnets.private.ids
  }
  depends_on = [module.network]
}

data "aws_instances" "app" {
  depends_on = [module.application]

  filter {
    name   = "tag:Component"
    values = ["asg"]
  }

  filter {
    name   = "tag:Environment"
    values = [var.project_config.env_name]
  }

  filter {
    name   = "tag:Project"
    values = [lookup(var.project_config.tags, "Project", var.project_config.project_name)]
  }

  instance_state_names = ["pending", "running"]
}

module "ansible-config" {
  source = "./config-mgmt"
  count  = var.go_ansible ? 1 : 0

  key_name     = local.ssh_key_name
  project_name = var.project_config.project_name
  env_name     = var.project_config.env_name

  bastion_public_ip = try(module.application.bastion_instances[0].public_ip, null)
  app_private_ips   = data.aws_instances.app.private_ips

  rds_endpoint = try(module.database.rds.address, null)
  rds_port     = try(module.database.rds.port, 3306)
  rds_username = try(module.database.rds.username, "admin")

  depends_on = [
    module.application,
    module.database
  ]
}
