locals {
  create_rds = var.create_rds

  setting = {
    name                  = var.db_config.setting.name
    identifier            = var.db_config.setting.identifier
    engine                = var.db_config.setting.engine
    engine_version        = var.db_config.setting.engine_version
    instance_class        = var.db_config.setting.instance_class
    allocated_storage     = var.db_config.setting.allocated_storage
    max_allocated_storage = var.db_config.setting.max_allocated_storage
    storage_type          = var.db_config.setting.storage_type
    port                  = var.db_config.setting.port
    security_group_ids    = var.db_config.setting.security_group_ids
  }

  credetials = {
    username     = var.db_config.credentials.username
    password     = var.db_config.credentials.password
    password_ssm = var.db_config.credentials.password_ssm_parameter
  }
}


resource "aws_db_instance" "this" {
  identifier     = local.setting.identifier
  engine         = local.setting.engine
  engine_version = local.setting.engine_version
  instance_class = local.setting.instance_class

  username = local.credentials.name
  password = local.credentials.password
  db_name  = local.setting.name

  allocated_storage     = local.setting.allocated_storage
  max_allocated_storage = local.setting.max_allocated_storage
  storage_type          = local.setting.storage_type

  port                   = local.setting.port
  vpc_security_group_ids = local.setting.security_group_ids
  publicly_accessible    = false
}