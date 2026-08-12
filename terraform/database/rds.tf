locals {
  rds_config = {
    create_rds = var.rds_config.create_rds

    settings = {
      identifier            = var.rds_config.setting.identifier
      db_name               = var.rds_config.setting.db_name
      engine                = var.rds_config.setting.engine
      engine_version        = var.rds_config.setting.engine_version
      instance_class        = var.rds_config.setting.instance_class
      allocated_storage     = var.rds_config.setting.allocated_storage
      max_allocated_storage = var.rds_config.setting.max_allocated_storage
      storage_type          = var.rds_config.setting.storage_type
      port                  = var.rds_config.setting.port
      publicly_accessible   = var.rds_config.setting.publicly_accessible

      backup_retention_period = var.rds_config.setting.backup_retention_period
      backup_window           = var.rds_config.setting.backup_window
      maintenance_window      = var.rds_config.setting.maintenance_window
      skip_final_snapshot     = var.rds_config.setting.skip_final_snapshot
    }

    credentials = {
      username = var.rds_config.credentials.username
      password = var.rds_config.credentials.password
    }

    network = {
      subnet_ids         = var.rds_network_config.subnet_ids
      security_group_ids = var.rds_network_config.security_group_ids
    }
  }
  tags = merge(var.project_config.tags, { Component = "rds" })
}


module "rds_instance" {
  source = "../_modules/database/rds"

  project_name = var.project_config.project_name
  env_name     = var.project_config.env_name
  project_tags = local.tags

  db_create_rds = local.rds_config.create_rds

  db_identifier            = local.rds_config.settings.identifier
  db_name                  = local.rds_config.settings.db_name
  db_engine                = local.rds_config.settings.engine
  db_engine_version        = local.rds_config.settings.engine_version
  db_instance_class        = local.rds_config.settings.instance_class
  db_allocated_storage     = local.rds_config.settings.allocated_storage
  db_max_allocated_storage = local.rds_config.settings.max_allocated_storage
  db_storage_type          = local.rds_config.settings.storage_type
  db_port                  = local.rds_config.settings.port
  db_publicly_accessible   = local.rds_config.settings.publicly_accessible

  db_backup_retention_period = local.rds_config.settings.backup_retention_period
  db_backup_window           = local.rds_config.settings.backup_window
  db_maintenance_window      = local.rds_config.settings.maintenance_window

  db_skip_final_snapshot = local.rds_config.settings.skip_final_snapshot


  db_username               = local.rds_config.credentials.username
  db_password               = local.rds_config.credentials.password
  db_password_ssm_parameter = var.rds_config.credentials.password_ssm_parameter

  db_subnet_ids         = local.rds_config.network.subnet_ids
  db_security_group_ids = local.rds_config.network.security_group_ids

}
