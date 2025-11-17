locals {
  project_config = var.project_config
}
# PROJECT CONFIG
variable "project_config" {
  description = "Project-level parameters (project name, env, tags)"
  type = object({
    project_name = string
    env_name     = string
    tags         = map(string)
  })
}


# EC2 CONFIG
variable "ec2_config" {
  description = "User-supplied EC2 configuration. Networking is handled separately."
  type = object({
    bastion = object({
      count                       = number
      instance_type               = optional(string)
      ami_id                      = optional(string)
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

    app = object({
      count                       = number
      instance_type               = optional(string)
      ami_id                      = optional(string)
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

    db = object({
      count                       = number
      instance_type               = optional(string)
      ami_id                      = optional(string)
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


# ALB CONFIG 
variable "alb_config" {
  description = "Application Load Balancer config"
  type = object({
    create_alb = bool
    settings = optional(object({
      name                       = optional(string)
      load_balancer_type         = optional(string)
      internal                   = optional(bool)
      enable_deletion_protection = optional(bool)
      target_port                = optional(number)
      target_type                = optional(string)
      listener_port              = optional(number)
      protocol                   = optional(string)
      health_check_path          = optional(string)
      certificate_arn            = optional(string)
    }), null)
  })

  default = {
    create_alb = false
    settings   = null
  }
}

# EC2 NETWORK CONFIG
variable "ec2_network_config" {
  description = "EC2 networking dependencies (subnet IDs and security groups)"
  type = object({
    bastion = object({
      subnet_id = string
      sg_ids    = list(string)
    })
    app = object({
      subnet_id = string
      sg_ids    = list(string)
    })
    db = object({
      subnet_id = string
      sg_ids    = list(string)
    })
  })
}

# ALB NETWORK CONFIG
variable "alb_network_config" {
  description = "ALB networking dependencies (VPC, subnets, SG IDs)"
  type = object({
    vpc_id          = string
    subnets         = list(string)
    security_groups = list(string)
  })
}
