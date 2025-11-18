## DATABSE RDS CONFIG
rds_config = {
  create_rds = true

  setting = {
    identifier            = "eac-dev-db"
    db_name               = "appdb"
    engine                = "mariadb"
    engine_version        = "11.4.8"
    instance_class        = "db.t3.micro"
    allocated_storage     = 20
    max_allocated_storage = 100
    storage_type          = "gp3"
    port                  = 3306
    publicly_accessible   = false
    skip_final_snapshot   = true

    # BACKUP SETTINGS
    backup_retention_period = 0
    backup_window           = "03:00-04:00"
    maintenance_window      = "sun:01:00-sun:02:00"
  }

  credentials = {
    username               = "admin"
    password               = "StrongPassword123!" # OR leave "" when using SSM
    password_ssm_parameter = null                 # e.g. "/eac/dev/db/password"
  }
}

