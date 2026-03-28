data "aws_ssm_parameter" "db_password" {
  count = var.db_password_ssm_parameter != null && var.db_password == "" ? 1 : 0
  name  = var.db_password_ssm_parameter
}

locals {
  db_final_password = (
    var.db_password != "" ?
    var.db_password :
    try(nonsensitive(data.aws_ssm_parameter.db_password[0].value), null)
  )
}

resource "aws_db_subnet_group" "rds" {
  count = var.db_create_rds ? 1 : 0

  name       = var.db_identifier
  subnet_ids = var.db_subnet_ids

  tags = merge(
    var.project_tags,
    { Component = "rds-subnet-group" }
  )
}

resource "aws_db_instance" "this" {
  count = var.db_create_rds ? 1 : 0

  identifier     = var.db_identifier
  engine         = var.db_engine
  engine_version = var.db_engine_version
  instance_class = var.db_instance_class

  username = var.db_username
  password = local.db_final_password
  db_name  = var.db_name

  allocated_storage     = var.db_allocated_storage
  max_allocated_storage = var.db_max_allocated_storage
  storage_type          = var.db_storage_type
  port                  = var.db_port

  vpc_security_group_ids = var.db_security_group_ids
  db_subnet_group_name   = aws_db_subnet_group.rds[0].name
  publicly_accessible    = var.db_publicly_accessible

  backup_retention_period = var.db_backup_retention_period
  backup_window           = var.db_backup_window
  maintenance_window      = var.db_maintenance_window

  skip_final_snapshot = var.db_skip_final_snapshot

  tags = merge(
    var.project_tags,
    {
      Component = "database"
      Type      = "rds"
    }
  )
}
