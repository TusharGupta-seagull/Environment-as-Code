variable "create_rds" {
  type    = bool
  default = false
}

variable "db_config" {
  type = object({
    setting = object({
      name                  = string
      engine                = optional(string)
      engine_version        = optional(string)
      instance_class        = optional(string)
      allocated_storage     = optional(number)
      max_allocated_storage = optional(number)
      storage_type          = optional(string)
      port                  = optional(number)
      security_group_ids    = list(string)
    })

    credentials = object({
      username               = string
      password               = string
      password_ssm_parameter = optional(string)
    })
  })

  default = {
    setting = {
      identifier            = "EAC"
      name                  = "appdb"
      engine                = "mariadb"
      engine_version        = "11.4.8"
      instance_class        = "db.t3.micro"
      allocated_storage     = 20
      max_allocated_storage = null
      storage_type          = "gp3"
      port                  = 3306
      security_group_ids    = []
    }

    credentials = {
      username               = ""
      password               = ""
      password_ssm_parameter = null
    }
  }
}

