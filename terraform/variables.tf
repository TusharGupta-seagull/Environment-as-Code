# Root Module - variables.tf

# Provider Configuration
variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Name of the project, used for resource naming"
  type        = string
  default     = "EAC"
}

variable "env_name" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default = {
    Terraform   = "true"
    Environment = "dev"
    Project     = "EAC"
  }
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

variable "ami_id" {
  description = "AMI ID for EC2 instances (leave null to use latest Amazon Linux 2023)"
  type        = string
  default     = null
}

variable "key_name" {
  description = "Name of the SSH key pair for EC2 access"
  type        = string
  default     = "eac-ssh-key"
}



variable "allowed_ssh_cidr" {
  description = "CIDR block allowed to SSH into EC2 instances"
  type        = string
  default     = "0.0.0.0/0"
}
variable "create_alb" {
  description = "Whether to create an Application Load Balancer"
  type        = bool
  default     = true
}
