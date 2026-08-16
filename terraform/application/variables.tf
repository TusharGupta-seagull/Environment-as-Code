locals {
  name_prefix = "${var.project_config.project_name}-${var.project_config.env_name}"
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

# EC2 NETWORK CONFIG
variable "ec2_network_config" {
  description = "EC2 networking dependencies (subnet IDs and security groups)"
  type = object({
    bastion = object({
      subnet_id = string
      sg_ids    = list(string)
    })
    app = object({
      subnet_ids = list(string)
      sg_ids     = list(string)
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

variable "services" {
  description = "Application services running behind the ALB. `ami_id` is the REQUIRED golden image — the ASG launch template uses it exclusively (no SSM fallback)"
  type = map(object({
    port                 = number
    health_path          = string
    instance_type        = optional(string)
    ami_id               = string # REQUIRED: golden image from the build pipeline
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
