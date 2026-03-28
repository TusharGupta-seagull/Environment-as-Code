
variable "project_name" {
  type        = string
  description = "Project name"
}

variable "env_name" {
  type        = string
  description = "Environment name"
}

variable "project_tags" {
  type        = map(string)
  description = "Tags to apply to all project resources"
}

variable "db_create_rds" {
  type        = bool
  description = "Whether to create RDS instance"
  default     = false
}

variable "db_identifier" {
  type    = string
  default = "eac-db"
}

variable "db_name" {
  type    = string
  default = "appdb"
}

variable "db_engine" {
  type    = string
  default = "mariadb"
}

variable "db_engine_version" {
  type    = string
  default = "11.4.8"
}

variable "db_instance_class" {
  type    = string
  default = "db.t3.micro"
}

variable "db_allocated_storage" {
  type    = number
  default = 20
}

variable "db_max_allocated_storage" {
  type    = number
  default = null
}

variable "db_storage_type" {
  type    = string
  default = "gp3"
}

variable "db_port" {
  type    = number
  default = 3306
}

variable "db_publicly_accessible" {
  type    = bool
  default = false
}

variable "db_skip_final_snapshot" {
  type    = bool
  default = true
}

variable "db_backup_retention_period" {
  type    = number
  default = 7
}

variable "db_backup_window" {
  type    = string
  default = "03:00-04:00"
}

variable "db_maintenance_window" {
  type    = string
  default = "sun:03:00-sun:04:00"
}



variable "db_username" {
  type    = string
  default = "admin"
}

variable "db_password" {
  type    = string
  default = ""
}

variable "db_password_ssm_parameter" {
  type    = string
  default = null
}


variable "db_subnet_ids" {
  type        = list(string)
  description = "RDS subnet IDs"
}

variable "db_security_group_ids" {
  type        = list(string)
  description = "RDS security groups"
}
