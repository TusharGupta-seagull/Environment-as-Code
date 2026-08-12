locals {
  ec2_config = {
    bastion = {
      count         = var.ec2_config.bastion.count
      instance_type = var.ec2_config.bastion.instance_type
      key_name      = var.ec2_config.key_name

      subnet_id = var.ec2_network_config.bastion.subnet_id
      sg_ids    = var.ec2_network_config.bastion.sg_ids

      # Bastion always runs Amazon Linux (AL2023 resolved via SSM)
      ami_id_ssm_parameter        = var.default_ami_id_ssm_parameter
      user_data                   = var.ec2_config.bastion.user_data
      availability_zone           = var.ec2_config.bastion.availability_zone
      associate_public_ip_address = var.ec2_config.bastion.associate_public_ip_address

      root_block_device = coalesce(var.ec2_config.bastion.root_block_device, {
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
  ami_id_ssm_parameter        = local.ec2_config.bastion.ami_id_ssm_parameter
  user_data                   = local.ec2_config.bastion.user_data
  availability_zone           = local.ec2_config.bastion.availability_zone
  root_block_device           = local.ec2_config.bastion.root_block_device

  tags = var.project_config.tags
  instance_tags = {
    Component = "bastion"
  }
}
