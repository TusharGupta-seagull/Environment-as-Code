variable "name" {
  description = "Name of the Load Balancer"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID for target group"
  type        = string
}

variable "subnets" {
  description = "Subnets for the load balancer"
  type        = list(string)
}

variable "security_groups" {
  description = "Security groups (only used for ALB)"
  type        = list(string)
  default     = []
}

variable "load_balancer_type" {
  description = "Type of Load Balancer (application, network, or gateway)"
  type        = string
  default     = "application"
  validation {
    condition     = contains(["application", "network", "gateway"], var.load_balancer_type)
    error_message = "load_balancer_type must be one of: application, network, gateway"
  }
}

variable "internal" {
  description = "Whether the LB is internal"
  type        = bool
  default     = false
}

variable "enable_deletion_protection" {
  description = "Enable deletion protection"
  type        = bool
  default     = false
}

variable "target_instance_ids" {
  description = "List of target instance IDs (for ALB/NLB)"
  type        = list(string)
  default     = []
}

variable "target_port" {
  description = "Target port"
  type        = number
  default     = 80
}

variable "target_type" {
  description = "Target type: instance, ip, or lambda"
  type        = string
  default     = "instance"
}

variable "listener_port" {
  description = "Listener port (only for ALB/NLB)"
  type        = number
  default     = 80
}

variable "protocol" {
  description = "Protocol for listener (HTTP, TCP, or GENEVE)"
  type        = string
  default     = "HTTP"
}

variable "health_check_path" {
  description = "Health check path (for ALB)"
  type        = string
  default     = "/"
}

variable "certificate_arn" {
  description = "ACM certificate ARN for HTTPS (optional)"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags to apply"
  type        = map(string)
  default     = {}
}