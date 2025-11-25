locals {
  ec2_config = {

    bastion = {
      count         = lookup(var.ec2_config.bastion, "count", 0)
      instance_type = lookup(var.ec2_config.bastion, "instance_type", "t3.micro")
      key_name      = var.ec2_config.key_name

      subnet_id = lookup(var.ec2_network_config.bastion, "subnet_id", null)
      sg_ids    = lookup(var.ec2_network_config.bastion, "sg_ids", [])

      ami_id                      = lookup(var.ec2_config.bastion, "ami_id", null)
      user_data                   = lookup(var.ec2_config.bastion, "user_data", null)
      availability_zone           = lookup(var.ec2_config.bastion, "availability_zone", null)
      associate_public_ip_address = lookup(var.ec2_config.bastion, "associate_public_ip_address", true)

      root_block_device = lookup(var.ec2_config.bastion, "root_block_device", {
        delete_on_termination = true
        volume_type           = "gp3"
        volume_size           = 10
        encrypted             = true
      })
    }

    app = {
      count         = lookup(var.ec2_config.app, "count", 0)
      instance_type = lookup(var.ec2_config.app, "instance_type", "t3.small")
      key_name      = var.ec2_config.key_name

      subnet_id = lookup(var.ec2_network_config.app, "subnet_id", null)
      sg_ids    = lookup(var.ec2_network_config.app, "sg_ids", [])

      ami_id                      = lookup(var.ec2_config.app, "ami_id", null)
      user_data                   = lookup(var.ec2_config.app, "user_data", null)
      availability_zone           = lookup(var.ec2_config.app, "availability_zone", null)
      associate_public_ip_address = lookup(var.ec2_config.app, "associate_public_ip_address", false)

      root_block_device = lookup(var.ec2_config.app, "root_block_device", {
        delete_on_termination = true
        volume_type           = "gp3"
        volume_size           = 10
        encrypted             = true
      })
    }

    db = {
      count         = lookup(var.ec2_config.db, "count", 0)
      instance_type = lookup(var.ec2_config.db, "instance_type", "t3.small")
      key_name      = var.ec2_config.key_name

      subnet_id = lookup(var.ec2_network_config.db, "subnet_id", null)
      sg_ids    = lookup(var.ec2_network_config.db, "sg_ids", [])

      ami_id                      = lookup(var.ec2_config.db, "ami_id", null)
      user_data                   = lookup(var.ec2_config.db, "user_data", null)
      availability_zone           = lookup(var.ec2_config.db, "availability_zone", null)
      associate_public_ip_address = lookup(var.ec2_config.db, "associate_public_ip_address", false)

      root_block_device = lookup(var.ec2_config.db, "root_block_device", {
        delete_on_termination = true
        volume_type           = "gp3"
        volume_size           = 10
        encrypted             = true
      })
    }

  }
}


module "bastion_instances" {
  source = "../_modules/compute/ec2-instance"
  count  = local.ec2_config.bastion.count

  create = true
  name   = "${local.name_prefix}-bastion-${count.index + 1}"

  instance_type               = local.ec2_config.bastion.instance_type
  subnet_id                   = local.ec2_config.bastion.subnet_id
  key_name                    = local.ec2_config.bastion.key_name
  vpc_security_group_ids      = local.ec2_config.bastion.sg_ids
  associate_public_ip_address = local.ec2_config.bastion.associate_public_ip_address
  ami_id                      = local.ec2_config.bastion.ami_id
  user_data                   = local.ec2_config.bastion.user_data
  availability_zone           = local.ec2_config.bastion.availability_zone
  root_block_device           = local.ec2_config.bastion.root_block_device

  tags = var.project_config.tags
  instance_tags = {
    Role        = "jump-server"
    Environment = var.project_config.env_name
  }
}

module "app_instances" {
  source = "../_modules/compute/ec2-instance"
  count  = local.ec2_config.app.count

  create = true
  name   = "${var.project_config.project_name}-${var.project_config.env_name}-app-${count.index + 1}"

  instance_type               = local.ec2_config.app.instance_type
  subnet_id                   = local.ec2_config.app.subnet_id
  key_name                    = local.ec2_config.app.key_name
  vpc_security_group_ids      = local.ec2_config.app.sg_ids
  associate_public_ip_address = local.ec2_config.app.associate_public_ip_address
  ami_id                      = local.ec2_config.app.ami_id
  user_data                   = local.ec2_config.app.user_data
  availability_zone           = local.ec2_config.app.availability_zone
  root_block_device           = local.ec2_config.app.root_block_device

  tags = var.project_config.tags
  instance_tags = {
    Role        = "app-server"
    Environment = var.project_config.env_name
  }
}

module "db_instances" {
  source = "../_modules/compute/ec2-instance"
  count  = local.ec2_config.db.count

  create = true
  name   = "${var.project_config.project_name}-${var.project_config.env_name}-db-${count.index + 1}"

  instance_type               = local.ec2_config.db.instance_type
  subnet_id                   = local.ec2_config.db.subnet_id
  key_name                    = local.ec2_config.db.key_name
  vpc_security_group_ids      = local.ec2_config.db.sg_ids
  associate_public_ip_address = local.ec2_config.db.associate_public_ip_address
  ami_id                      = local.ec2_config.db.ami_id
  availability_zone           = local.ec2_config.db.availability_zone
  root_block_device           = local.ec2_config.db.root_block_device

  tags = var.project_config.tags
  instance_tags = {
    Role        = "db-server"
    Environment = var.project_config.env_name
  }
}
