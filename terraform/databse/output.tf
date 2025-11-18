output "rds" {
  description = "RDS instance details"
  value = {
    enabled        = local.rds_config.create_rds

    identifier     = try(module.rds_instance[0].identifier, null)
    db_name        = try(module.rds_instance[0].db_name, null)

    endpoint       = try(module.rds_instance[0].endpoint, null)
    address        = try(module.rds_instance[0].address, null)
    port           = try(module.rds_instance[0].port, null)

    username       = try(module.rds_instance[0].username, null)
    engine         = try(module.rds_instance[0].engine, null)
    engine_version = try(module.rds_instance[0].engine_version, null)

    subnet_group   = try(module.rds_instance[0].subnet_group, null)
    security_groups = try(module.rds_instance[0].security_group_ids, null)

    writer_connection_string = try("${module.rds_instance[0].address}:${module.rds_instance[0].port}", null)
    mysql_cli                = try("mysql -h ${module.rds_instance[0].address} -P ${module.rds_instance[0].port} -u ${module.rds_instance[0].username} -p", null)
  }
}
