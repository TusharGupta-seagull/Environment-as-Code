locals {
  tags = merge(var.project_config.tags, { Component = "rds" })
}

module "rds_instance" {
  source = "../_modules/database/rds"

  project_name = var.project_config.project_name
  env_name     = var.project_config.env_name
  project_tags = local.tags

  db_create_rds = var.rds_config.create_rds

  db_identifier            = var.rds_config.setting.identifier
  db_name                  = var.rds_config.setting.db_name
  db_engine                = var.rds_config.setting.engine
  db_engine_version        = var.rds_config.setting.engine_version
  db_instance_class        = var.rds_config.setting.instance_class
  db_allocated_storage     = var.rds_config.setting.allocated_storage
  db_max_allocated_storage = var.rds_config.setting.max_allocated_storage
  db_storage_type          = var.rds_config.setting.storage_type
  db_port                  = var.rds_config.setting.port
  db_publicly_accessible   = var.rds_config.setting.publicly_accessible

  db_backup_retention_period = var.rds_config.setting.backup_retention_period
  db_backup_window           = var.rds_config.setting.backup_window
  db_maintenance_window      = var.rds_config.setting.maintenance_window

  db_skip_final_snapshot = var.rds_config.setting.skip_final_snapshot

  db_username               = var.rds_config.credentials.username
  db_password               = var.rds_config.credentials.password
  db_password_ssm_parameter = var.rds_config.credentials.password_ssm_parameter

  db_subnet_ids         = var.rds_network_config.subnet_ids
  db_security_group_ids = var.rds_network_config.security_group_ids
}
