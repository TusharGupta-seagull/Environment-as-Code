variable "project_config" {
  type = any
}
variable "rds_config" {
  type = object({
    create_rds = bool
    setting = object({
      identifier              = string
      db_name                 = string
      engine                  = optional(string)
      engine_version          = optional(string)
      instance_class          = optional(string)
      allocated_storage       = optional(number)
      max_allocated_storage   = optional(number)
      storage_type            = optional(string)
      port                    = optional(number)
      publicly_accessible     = optional(bool)
      skip_final_snapshot     = optional(bool)
      backup_retention_period = optional(number)
      backup_window           = optional(string)
      maintenance_window      = optional(string)
    })

    credentials = object({
      username               = string
      password               = string
      password_ssm_parameter = optional(string)
    })
  })

  default = {
    create_rds = false

    setting = {
      identifier              = "EAC-DB"
      db_name                 = "appdb"
      engine                  = "mariadb"
      engine_version          = "11.4.8"
      instance_class          = "db.t3.micro"
      allocated_storage       = 20
      max_allocated_storage   = null
      storage_type            = "gp3"
      port                    = 3306
      publicly_accessible     = false
      skip_final_snapshot     = true
      backup_retention_period = null
      backup_window           = null
      maintenance_window      = null
    }

    credentials = {
      username = ""
      password = ""
    }
  }
}

variable "rds_network_config" {
  type = object({
    subnet_ids         = list(string)
    security_group_ids = list(string)
  })
}
