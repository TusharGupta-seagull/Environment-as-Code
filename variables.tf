# Root Module - variables.tf

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
  }
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "map_public_ip_on_launch" {
  description = "Whether to map public IP addresses on launch for public subnets"
  type        = bool
  default     = true
}

variable "public_subnets" {
  description = "List of public subnet configurations"
  type = list(object({
    cidr       = string
    avail_zone = optional(string)
  }))
  default = [
    {
      cidr       = "10.0.1.0/24"
      avail_zone = "us-east-1a"
    },
    {
      cidr       = "10.0.2.0/24"
      avail_zone = "us-east-1b"
    }
  ]
}

variable "private_subnets" {
  description = "List of private subnet configurations"
  type = list(object({
    cidr             = string
    enable_nat_route = bool
    avail_zone       = optional(string)
  }))
  default = [
    {
      cidr             = "10.0.10.0/24"
      enable_nat_route = true
      avail_zone       = "us-east-1b"
    }
  ]
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
  default     = "ssh-key"
}

variable "ec2_user" {
  description = "Name of the user for SSH into the ec2 instances"
  type        = string
  default     = "ec2-user"
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

variable "alb_config" {
  description = "Configuration for the Application Load Balancer"
  type = object({
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
  })

  default = {
    load_balancer_type         = "application"
    internal                   = false
    enable_deletion_protection = false
    target_port                = 80
    target_type                = "instance"
    listener_port              = 80
    protocol                   = "HTTP"
    health_check_path          = "/"
    certificate_arn            = ""
  }
}


