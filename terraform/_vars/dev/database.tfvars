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

  # Password precedence (root main.tf):
  #   1. TF_VAR_db_password env var set on the Jenkins agent (e.g., fetched from Vault)
  #   2. An existing SSM SecureString parameter (db_password_ssm_parameter)
  #   3. Terraform generates a random password and stores it in SSM (SecureString)
  # No plaintext secrets live in this repo.
  credentials = {
    username = "admin"
    password = ""
  }
}

