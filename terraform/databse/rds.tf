locals {
  rds_config = {

    create_rds = lookup(var.rds_config, "create_rds", false)

    settings = {
      identifier            = lookup(var.rds_config.setting, "identifier", "${var.project_config.project_name}-${var.project_config.env_name}-rds")
      db_name              = lookup(var.rds_config.setting, "db_name", "myDB")
      engine                = lookup(var.rds_config.setting, "engine", "mariards")
      engine_version        = lookup(var.rds_config.setting, "engine_version", "11.4.8")
      instance_class        = lookup(var.rds_config.setting, "instance_class", "rds.t3.micro")
      allocated_storage     = lookup(var.rds_config.setting, "allocated_storage", 20)
      max_allocated_storage = lookup(var.rds_config.setting, "max_allocated_storage", null)
      storage_type          = lookup(var.rds_config.setting, "storage_type", "gp3")
      port                  = lookup(var.rds_config.setting, "port", 3306)
      publicly_accessible   = lookup(var.rds_config.setting, "publicly_accessible", false)

      backup_retention_period = lookup(var.rds_config.setting, "backup_retention_period", null)
      backup_window           = lookup(var.rds_config.setting, "backup_window", null)
      maintenance_window      = lookup(var.rds_config.setting, "maintenance_window", null)
    }

    credentials = {
      username = lookup(var.rds_config.credentials, "username", null)
      password = lookup(var.rds_config.credentials, "password", null)
    }

    network = {
      subnet_ids         = lookup(var.rds_network_config, "subnet_ids", [])
      security_group_ids = lookup(var.rds_network_config, "security_group_ids", [])
    }
  }
  tags = merge(var.project_config.tags,
  { "type" = "rds-db-${var.project_config.project_name}" })
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

  db_skip_final_snapshot = true


  db_username               = local.rds_config.credentials.username
  db_password               = local.rds_config.credentials.password
  db_password_ssm_parameter = var.rds_config.credentials.password_ssm_parameter

  db_subnet_ids         = local.rds_config.network.subnet_ids
  db_security_group_ids = local.rds_config.network.security_group_ids

}
