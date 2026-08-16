output "rds" {
  description = "RDS instance details"
  value = {
    enabled = var.rds_config.create_rds

    identifier = try(module.rds_instance.rds_db_name, null)
    db_name    = try(module.rds_instance.rds_db_name, null)

    endpoint = try(module.rds_instance.rds_endpoint, null)
    address  = try(module.rds_instance.rds_endpoint, null)
    port     = try(module.rds_instance.rds_port, null)

    username       = try(module.rds_instance.rds_username, null)
    engine         = try(module.rds_instance.rds_engine, null)
    engine_version = try(module.rds_instance.rds_engine_version, null)

    subnet_group    = try(module.rds_instance.rds_subnet_group, null)
    security_groups = try(module.rds_instance.rds_security_groups, null)

    writer_connection_string = try("${module.rds_instance.rds_endpoint}:${module.rds_instance.rds_port}", null)
    mysql_cli                = try("mysql -h ${module.rds_instance.rds_endpoint} -P ${module.rds_instance.rds_port} -u ${module.rds_instance.rds_username} -p", null)
  }
}
