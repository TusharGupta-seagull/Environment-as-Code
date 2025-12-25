variable "create" {
  description = "Flag to create the Auto Scaling Group"
  type    = bool
  default = true
}

variable "name_prefix" {
  description = "Name prefix for the Auto Scaling Group resources"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for the Auto Scaling Group"
  type = list(string)
}

variable "security_group_ids" {
  description = "List of security group IDs for the instances"
  type = list(string)
}

variable "target_group_arns" {
  description = "List of target group ARNs to attach to the Auto Scaling Group"
  type = list(string)
}

variable "ami_id" {
  description = "Golden AMI ID (highest priority)"
  type        = string
  default     = null
}

variable "ami_id_ssm_parameter" {
  description = "SSM parameter name for fallback AMI resolution"
  type        = string
  default     = null
}

variable "instance_type" {
  description = "EC2 instance type"
  type = string
}

variable "key_name" {
  description = "Key pair name for SSH access"
  type    = string
  default = null
}

variable "iam_instance_profile" {
  description = "IAM instance profile name"
  type    = string
  default = null
}

variable "user_data" {
  description = "User data script (already rendered)"
  type        = string
  default     = null
}

variable "min_size" {
  description = "Minimum size of the Auto Scaling Group"
  type = number
}

variable "max_size" {
  description = "Maximum size of the Auto Scaling Group"
  type = number
}

variable "desired_capacity" {
  description = "Desired capacity of the Auto Scaling Group"
  type = number
}

variable "health_check_type" {
  description = "Health check type for the Auto Scaling Group"
  type    = string
  default = "ELB"
}

variable "health_check_grace_period" {
  description = "Health check grace period in seconds"
  type    = number
  default = 300
}

variable "cpu_target_value" {
  description = "Target CPU utilization percentage"
  type        = number
  default     = 60
}

variable "enable_memory_scaling" {
  description = "Enable memory-based scaling (CloudWatch Agent required)"
  type        = bool
  default     = false
}

variable "memory_high_threshold" {
  description = "Memory utilization percentage to scale out"
  type        = number
  default     = 75
}

variable "tags" {
  description = "Tags to apply to all resources"
  type    = map(string)
  default = {}
}

variable "instance_tags" {
  type    = map(string)
  default = {}
}
