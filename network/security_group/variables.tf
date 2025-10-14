variable "create_sg" {
  description = "Flag to create a security group"
  type        = bool
  default     = true
}

variable "sg_name" {
  description = "Name to be used on Security Group"
  type        = string
  default     = null
  validation {
    condition     = var.sg_name == null || (length(var.sg_name) > 0 && length(var.sg_name) <= 255)
    error_message = "Security group name must be between 1 and 255 characters."
  }
}

variable "sg_description" {
  description = "Description for the security group"
  type        = string
  default     = null
}

variable "sg_vpc_id" {
  description = "VPC ID to create the security group in"
  type        = string
  default     = null
  validation {
    condition = var.sg_vpc_id != null && var.sg_vpc_id != ""
    error_message = "VPC ID is required when creating security group"
  }
}

variable "sg_egress_rules" {
  description = "Egress rules"
  type = map(object({
    cidr_ipv4                    = optional(string)
    from_port                    = optional(number)
    to_port                      = optional(number)
    ip_protocol                  = optional(string, "tcp")
    description                  = optional(string)
    prefix_list_id               = optional(string)
    referenced_security_group_id = optional(string)
    tags                         = optional(map(string), {})
  }))
  default = {
    ipv4_default = {
      cidr_ipv4   = "0.0.0.0/0"
      from_port = 0
      to_port = 0
      ip_protocol = "-1"
      description = "Allow all IPv4 traffic"
    }
  }
}

variable "sg_ingress_rules" {
  description = "Ingress rules"
  type = map(object({
    cidr_ipv4                    = optional(string)
    from_port                    = optional(number)
    to_port                      = optional(number)
    ip_protocol                  = optional(string, "tcp")
    description                  = optional(string)
    prefix_list_id               = optional(string)
    referenced_security_group_id = optional(string)
    tags                         = optional(map(string), {})
  }))
  default = null
}

variable "tags" {
  description = "A map of tags to assign to the resource"
  type        = map(string)
  default     = {}
}

variable "sg_tags" {
  description = "A map of additional tags to add to the security group"
  type        = map(string)
  default     = {}
}