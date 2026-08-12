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
  description = "SSH users: bastion_user logs into the bastion, app_db_user is the user on app/db instances"
  type        = map(string)
  default = {
    bastion_user = "ec2-user"
    app_db_user  = "ec2-user"
  }
}

variable "bastion_public_ip" {
  description = "Public IP of the bastion host (the only Ansible target)"
  type        = string
  default     = ""
}

variable "app_private_ips" {
  description = "Private IPs of the ASG-managed application instances"
  type        = list(string)
  default     = []
}

variable "ssh_private_key_path" {
  description = "Local path to the SSH private key used by Ansible. When null, defaults to ansible/<key_name>.pem"
  type        = string
  default     = null
}

variable "instance_wait_seconds" {
  description = "Seconds to wait after apply before running the Ansible playbook (lets instances boot)"
  type        = number
  default     = 120
}

variable "rds_endpoint" {
  description = "RDS instance endpoint (used for the bastion's MySQL access)"
  type        = string
  default     = ""
}

variable "rds_port" {
  description = "RDS instance port"
  type        = number
  default     = 3306
}

variable "rds_username" {
  description = "RDS master username"
  type        = string
  default     = "admin"
}
