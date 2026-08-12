# Root Module - variables.tf

# Provider Configuration
variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
  default     = "ap-south-1"
}

variable "project_config" {
  description = "Project-level parameters (project name, env, tags)"
  type = object({
    project_name = string
    env_name     = string
    tags         = map(string)
  })
}
variable "network_config" {
  description = "Complete network configuration including VPC, subnets, SG settings"
  type = object({
    vpc = object({
      cidr = string
    })

    subnets = object({
      public = list(object({
        cidr       = string
        avail_zone = optional(string)
      }))

      private = list(object({
        cidr             = string
        enable_nat_route = bool
        avail_zone       = optional(string)
      }))
    })

    settings = object({
      map_public_ip_on_launch = map(bool)
      create_alb              = bool
      allowed_ssh_cidr        = string
    })
  })
}

variable "ec2_config" {
  description = "User-supplied EC2 configuration. Networking is handled separately."
  type = object({
    bastion = object({
      count         = number
      instance_type = optional(string)
      # AMI is not configurable: the bastion always runs Amazon Linux (AL2023 via SSM)
      user_data                   = optional(string)
      availability_zone           = optional(string)
      associate_public_ip_address = optional(bool)
      root_block_device = optional(object({
        delete_on_termination = optional(bool)
        volume_type           = optional(string)
        volume_size           = optional(number)
        encrypted             = optional(bool)
      }))
    })

    key_name = string
  })
}
variable "rds_config" {
  description = "RDS database configuration"
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

variable "alb_config" {
  description = "Application Load Balancer config"
  type = object({
    create_alb = bool
    settings = optional(object({
      name                       = optional(string)
      load_balancer_type         = optional(string)
      internal                   = optional(bool)
      enable_deletion_protection = optional(bool)
      listener_port              = optional(number)
      protocol                   = optional(string)
      certificate_arn            = optional(string)
    }), null)
  })

  default = {
    create_alb = false
    settings   = null
  }
}

variable "go_ansible" {
  description = "Run the Ansible bastion provisioning after apply"
  type        = bool
  default     = false

}

variable "services" {
  description = "Configuration for different services/part of application (e.g., auth, judge, cart, etc.)"
  type = map(object({
    port                 = number
    health_path          = string
    instance_type        = optional(string)
    ami_id               = string # REQUIRED: golden image from the build pipeline; the ASG launch template uses it exclusively
    user_data            = optional(string)
    iam_instance_profile = optional(string)
    min_size             = number
    max_size             = number
    desired              = number
  }))

  validation {
    condition     = alltrue([for s in var.services : s.ami_id != null])
    error_message = "services[].ami_id (golden image) is required: the ASG launch template must use the golden AMI."
  }
}

variable "default_ami_id_ssm_parameter" {
  description = "SSM parameter for the Amazon Linux AMI used by the bastion host (the bastion always runs Amazon Linux; the golden image is reserved for the ASG launch template)"
  type        = string
  default     = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

variable "ssh_key_pair_name" {
  description = "Name of an existing AWS key pair to use for all instances. When set, no key is generated and re-applies can never invalidate instance keys. When null, a key pair is generated on first apply."
  type        = string
  default     = null
}

variable "ssh_private_key_path" {
  description = "Local path to the private key file for ssh_key_pair_name (required by the Ansible bastion provisioning when using an existing key pair). Ignored when a key is generated."
  type        = string
  default     = null
}

variable "db_password" {
  description = "RDS password supplied via the TF_VAR_db_password env var on the Jenkins agent (e.g., fetched from Vault). When null, terraform falls back to db_password_ssm_parameter, or generates a random password stored in SSM Parameter Store."
  type        = string
  default     = null
  sensitive   = true
}

variable "db_password_ssm_parameter" {
  description = "Name of an existing SSM SecureString parameter containing the RDS password. Used when db_password is null. When both are null, terraform generates a password and stores it in SSM on first apply (no plaintext in the repo)."
  type        = string
  default     = null
}
