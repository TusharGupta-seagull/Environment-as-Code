locals {
  ec2_config = {
    bastion = {
      count         = var.ec2_config.bastion.count
      instance_type = "t3.micro"
      subnet_id = var.ec2_config.bastion.subnet_id
      sg_ids    = var.ec2_config.bastion.sg_ids
      key_name  = var.ec2_config.key_name

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
      count = var.ec2_config.app.count
      instance_type = "t3.small"
      subnet_id = var.ec2_config.app.subnet_id
      sg_ids    = var.ec2_config.app.sg_ids
      key_name  = var.ec2_config.key_name
      user_data = var.ec2_config.app.user_data

      associate_public_ip_address = false
      root_block_device = {
        delete_on_termination = true
        volume_type           = "gp3"
        volume_size           = 10
        encrypted             = true
      }
    }

    db = {
      count = var.ec2_config.db.count
      instance_type = "t3.small"

      subnet_id = var.ec2_config.db.subnet_id
      sg_ids    = var.ec2_config.db.sg_ids
      key_name  = var.ec2_config.key_name

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



# EC2 Instances Module

## instance for bastion host
module "bastion_instances" {
  source = "../_modules/compute/ec2-instance"
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

}

## instance for application
module "app_instances" {
  source = "../_modules/compute/ec2-instance"
  count  = local.ec2_config["app"].count

  create = true
  name   = "${var.project_name}-${var.env_name}-app-${count.index + 1}"

  instance_type               = local.ec2_config["app"].instance_type
  subnet_id                   = local.ec2_config["app"].subnet_id
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
}

## instance for database
module "db_instances" {
  source = "../_modules/compute/ec2-instance"
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
}
