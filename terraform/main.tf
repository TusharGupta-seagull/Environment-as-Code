# Root Module - main.tf

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

# NETWORK -> VPC, SUBNETS, SECURITY_GROUP, ROUTE53
module "network" {
  source = "./network"
}


# Application Instances -> APP, DB, BASTION, LB
module "application_instances" {
  source = "./application"

  project_name = var.project_name
  tags         = var.tags

  ec2_config = {
    bastion = {
      count         = 1
      instance_type = "t3.micro"
      subnet_id     = module.network.subnets.public.ids[0]
      sg_ids        = [module.network.security_groups.bastion.id]

    },
    app = {
      count         = 2
      instance_type = "t3.micro"
      subnet_id     = module.network.subnets.private.ids[0]
      sg_ids        = [module.network.security_groups.app.id]
      user_data = file("${path.module}/test/script-1.sh")

    },
    db = {
      count         = 1
      instance_type = "t3.micro"
      subnet_id     = module.network.subnets.private.ids[0]
      sg_ids        = [module.network.security_groups.db.id]
    },
    key_name = var.key_name
  }
  alb_config = {
    settings = {
      name                       = "${var.project_name}-${var.env_name}-alb"
      load_balancer_type         = "application"
      internal                   = false
      enable_deletion_protection = false
      target_port                = 80
      target_type                = "instance"
      listener_port              = 80
      protocol                   = "HTTP"
      health_check_path          = "/"
      certificate_arn            = ""
    }

    infra = {
      vpc_id          = module.network.vpc.id
      subnets         = module.network.subnets.public.ids
      security_groups = [module.network.security_groups.alb.id]
    }
  }
  depends_on = [module.network, aws_key_pair.ansible_key]
}

# module "ansible-config" {
#   source = "./config-mgmt"
#   application_instance_ips = {
#     app_private_ips   = [for ins in module.application_instances.app_instances : ins.private_ip]
#     db_private_ips    = [for ins in module.application_instances.db_instances : ins.private_ip]
#     bastion_public_ip = module.application_instances.bastion_instances[0].public_ip
#   }
#   depends_on = [
#     module.application_instances
#   ]
# }

