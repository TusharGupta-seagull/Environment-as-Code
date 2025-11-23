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

variable "key_name" {
  description = "Name of the SSH key pair for EC2 access"
  type        = string
  default     = "eac-ssh-key"
}

variable "ssh_user" {
  description = "Name of the user for SSH into the ec2 instances"
  type        = map(string)
  default = {
    bastion_user = "ubuntu"
    app_db_user  = "ec2-user"
  }
}

variable "application_instance_ips" {
  type = object({
    bastion_public_ip = string
    app_private_ips   = list(string)
    db_private_ips    = list(string)
  })
  default = {
    app_private_ips   = [""]
    db_private_ips    = [""]
    bastion_public_ip = ""
  }
}
