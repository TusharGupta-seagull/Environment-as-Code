locals {
  create_instance = var.create

  ami = try(coalesce(
    var.ami_id,
    try(nonsensitive(data.aws_ssm_parameter.ami[0].value), null)
  ), null)

  tags = merge(
    var.tags,
    var.instance_tags,
    var.name != "" ? { Name = var.name } : {}
  )
}

data "aws_ssm_parameter" "ami" {
  count = local.create_instance && var.ami_id == null ? 1 : 0
  name  = var.ami_id_ssm_parameter
}


resource "aws_instance" "main" {
  count = local.create_instance ? 1 : 0

  dynamic "launch_template" {
    for_each = var.launch_template != null ? [var.launch_template] : []
    content {
      id      = launch_template.value.id
      name    = launch_template.value.name
      version = launch_template.value.version
    }
  }
  vpc_security_group_ids = var.vpc_security_group_ids

  associate_public_ip_address = var.associate_public_ip_address

  ami               = local.ami
  instance_type     = var.instance_type
  key_name          = var.key_name
  subnet_id         = var.subnet_id
  availability_zone = var.availability_zone
  user_data         = var.user_data

  dynamic "root_block_device" {
    for_each = var.root_block_device != null ? [var.root_block_device] : []
    content {
      delete_on_termination = lookup(root_block_device.value, "delete_on_termination", true)
      volume_type           = lookup(root_block_device.value, "volume_type", "gp3")
      volume_size           = lookup(root_block_device.value, "volume_size", 8)
      iops                  = lookup(root_block_device.value, "iops", null)
      throughput            = lookup(root_block_device.value, "throughput", null)
      encrypted             = lookup(root_block_device.value, "encrypted", false)
      kms_key_id            = lookup(root_block_device.value, "kms_key_id", null)
    }
  }

  tags = local.tags

  lifecycle {
    ignore_changes = [ami]
  }
}
