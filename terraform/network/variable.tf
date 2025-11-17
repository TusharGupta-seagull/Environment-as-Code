# Project Configuration
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

// VPC =====================================================================================
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "map_public_ip_on_launch" {
  description = "Whether to map public IP addresses on launch for public subnets"
  type        = map(bool)
  default = {
    pub_sub  = true
    priv_sub = false
  }
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

// Security Groups ===========================================================================================
variable "create_alb" {
  description = "Whether to create an Application Load Balancer"
  type        = bool
  default     = true
}

variable "allowed_ssh_cidr" {
  description = "CIDR block allowed to SSH into EC2 instances"
  type        = string
  default     = "0.0.0.0/0"
}

