variable "name" {
  description = "Name of the target group"
  type        = string
  default     = ""
}

variable "name_prefix" {
  description = "Name prefix for the target group"
  type        = string
  default     = ""
}

variable "port" {
  description = "Port on which targets receive traffic"
  type        = number
}

variable "protocol" {
  description = "Protocol to use for routing traffic to the targets"
  type        = string
  default     = "HTTP"
  validation {
    condition     = contains(["HTTP", "HTTPS", "TCP", "TLS", "UDP", "TCP_UDP", "GENEVE"], var.protocol)
    error_message = "Protocol must be one of: HTTP, HTTPS, TCP, TLS, UDP, TCP_UDP, GENEVE"
  }
}

variable "vpc_id" {
  description = "VPC ID where the target group will be created"
  type        = string
}

variable "target_type" {
  description = "Type of target (instance, ip, lambda, alb)"
  type        = string
  default     = "instance"
  validation {
    condition     = contains(["instance", "ip", "lambda", "alb"], var.target_type)
    error_message = "Target type must be one of: instance, ip, lambda, alb"
  }
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

variable "deregistration_delay" {
  description = "Time in seconds for deregistration delay"
  type        = number
  default     = 300
}

variable "connection_termination" {
  description = "Whether to terminate connections at the end of deregistration timeout"
  type        = bool
  default     = false
}

variable "preserve_client_ip" {
  description = "Whether client IP preservation is enabled"
  type        = string
  default     = null
}

variable "proxy_protocol_v2" {
  description = "Whether to enable proxy protocol v2"
  type        = bool
  default     = false
}

variable "slow_start" {
  description = "Time in seconds for slow start mode"
  type        = number
  default     = 0
}

variable "lambda_multi_value_headers_enabled" {
  description = "Whether multi-value headers are enabled for Lambda targets"
  type        = bool
  default     = false
}

variable "load_balancing_algorithm_type" {
  description = "Load balancing algorithm type"
  type        = string
  default     = "round_robin"
  validation {
    condition     = contains(["round_robin", "least_outstanding_requests", "weighted_random"], var.load_balancing_algorithm_type)
    error_message = "Load balancing algorithm must be one of: round_robin, least_outstanding_requests, weighted_random"
  }
}

variable "ip_address_type" {
  description = "IP address type for the target group"
  type        = string
  default     = "ipv4"
  validation {
    condition     = contains(["ipv4", "ipv6"], var.ip_address_type)
    error_message = "IP address type must be either ipv4 or ipv6"
  }
}

# Health Check Variables
variable "health_check_enabled" {
  description = "Whether health checks are enabled"
  type        = bool
  default     = true
}

variable "health_check_path" {
  description = "Health check path (for HTTP/HTTPS)"
  type        = string
  default     = "/"
}

variable "health_check_port" {
  description = "Port for health checks"
  type        = string
  default     = "traffic-port"
}

variable "health_check_protocol" {
  description = "Protocol for health checks"
  type        = string
  default     = ""
}

variable "health_check_interval" {
  description = "Health check interval in seconds"
  type        = number
  default     = 30
}

variable "health_check_timeout" {
  description = "Health check timeout in seconds"
  type        = number
  default     = 5
}

variable "health_check_healthy_threshold" {
  description = "Number of consecutive successful health checks"
  type        = number
  default     = 3
}

variable "health_check_unhealthy_threshold" {
  description = "Number of consecutive failed health checks"
  type        = number
  default     = 3
}

variable "health_check_matcher" {
  description = "HTTP codes to use for health checks"
  type        = string
  default     = "200-399"
}

# Stickiness Variables
variable "stickiness_enabled" {
  description = "Whether stickiness is enabled"
  type        = bool
  default     = false
}

variable "stickiness_type" {
  description = "Type of stickiness (lb_cookie, app_cookie, source_ip, source_ip_dest_ip, source_ip_dest_ip_proto)"
  type        = string
  default     = "lb_cookie"
}

variable "stickiness_cookie_duration" {
  description = "Cookie duration in seconds"
  type        = number
  default     = 86400
}

variable "stickiness_cookie_name" {
  description = "Name of the application cookie"
  type        = string
  default     = ""
}

# Target Failover Variables
variable "target_failover" {
  description = "Target failover configuration"
  type        = map(string)
  default     = {}
}

# Target Health State Variables
variable "target_health_state" {
  description = "Target health state configuration"
  type        = map(bool)
  default     = {}
}

# Targets
variable "targets" {
  description = "Map of targets to attach to the target group"
  type = map(object({
    target_id         = string
    port              = optional(number)
    availability_zone = optional(string)
  }))
  default = {}
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}