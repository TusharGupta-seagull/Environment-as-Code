# Root Module - variables.tf
# Variable definitions for the root module

# ==============================================================================
# General Configuration
# ==============================================================================
variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Name of the project, used for resource naming"
  type        = string
  default     = "MyProject"
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default = {
    Terraform   = "true"
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}

# ==============================================================================
# VPC Configuration
# ==============================================================================
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
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
      avail_zone       = "us-east-1a"
    },
    {
      cidr             = "10.0.11.0/24"
      enable_nat_route = true
      avail_zone       = "us-east-1b"
    }
  ]
}

variable "nat_gateway_subnet_cidr" {
  description = "CIDR of the public subnet where NAT Gateway should be placed"
  type        = string
  default     = null
}

# ==============================================================================
# EC2 Configuration
# ==============================================================================
variable "instance_count" {
  description = "Number of EC2 instances to create"
  type        = number
  default     = 2
  validation {
    condition     = var.instance_count > 0 && var.instance_count <= 10
    error_message = "Instance count must be between 1 and 10."
  }
}

variable "ami_id" {
  description = "AMI ID for EC2 instances (leave null to use latest Amazon Linux 2023)"
  type        = string
  default     = null
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "Name of the SSH key pair for EC2 access"
  type        = string
  default     = "my-terraform-key"
}

variable "root_volume_size" {
  description = "Size of the root EBS volume in GB"
  type        = number
  default     = 20
}

variable "enable_encryption" {
  description = "Enable EBS encryption"
  type        = bool
  default     = true
}

variable "user_data_script" {
  description = "User data script for EC2 instances"
  type        = string
  default     = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y httpd
    systemctl start httpd
    systemctl enable httpd
    echo "<h1>Hello from $(hostname -f)</h1>" > /var/www/html/index.html
  EOF
}

variable "allowed_ssh_cidr" {
  description = "CIDR block allowed to SSH into EC2 instances"
  type        = string
  default     = "0.0.0.0/0"
}

# ==============================================================================
# Load Balancer Configuration
# ==============================================================================
variable "create_alb" {
  description = "Whether to create an Application Load Balancer"
  type        = bool
  default     = true
}

variable "enable_deletion_protection" {
  description = "Enable deletion protection for the load balancer"
  type        = bool
  default     = false
}

variable "target_port" {
  description = "Port on which targets receive traffic"
  type        = number
  default     = 80
}

variable "health_check_path" {
  description = "Health check path for ALB target group"
  type        = string
  default     = "/"
}

variable "certificate_arn" {
  description = "ARN of ACM certificate for HTTPS listener (optional)"
  type        = string
  default     = ""
}