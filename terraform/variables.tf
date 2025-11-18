# Root Module - variables.tf

# Provider Configuration
variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
  default     = "us-east-1"
}

variable "project_config" {
  type = any
}
variable "network_config" {
  type = any
}

variable "ec2_config" {
  type = any
}
variable "rds_config" {
  type = any
}

variable "alb_config" {
  type = any
}

variable "go_ansibe" {
  type    = bool
  default = false
}

# variable "ec2_config" {
#   description = "Config for EC2 instances"
#   type = map(object({
#     count                       = optional(number)
#     instance_type               = string
#     subnet_id                   = string
#     key_name                    = string
#     sg_ids                      = list(string)
#     ami_id                      = optional(string)
#     user_data                   = optional(string)
#     availability_zone           = optional(string)
#     associate_public_ip_address = optional(bool)
#     root_block_device = optional(object({
#       delete_on_termination = optional(bool)
#       volume_type           = optional(string)
#       volume_size           = optional(number)
#       encrypted             = optional(bool)
#     }))
#   }))
# }
