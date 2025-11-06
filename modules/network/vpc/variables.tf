variable "project_name" {
  description = "Name of the project, used for resource naming"
  type        = string
}

variable "env_name" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
}

variable "tags" {
  description = "Common tags to apply to all VPC resources"
  type        = map(string)
  default     = {}
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "pub_cidrs" {
  description = "List of public subnet CIDR blocks with optional availability zones"
  type = list(object({
    cidr       = string
    avail_zone = optional(string)
  }))

  default = [
    {
      cidr       = "10.0.1.0/24"
      avail_zone = null
    }
  ]
}

variable "priv_cidrs" {
  description = "List of private subnet configurations with CIDR blocks and NAT route enablement"
  type = list(object({
    cidr             = string
    enable_nat_route = bool
    avail_zone       = optional(string)
  }))

  default = [
    {
      cidr             = "10.0.3.0/24"
      enable_nat_route = false
      avail_zone       = null
    }
  ]
}

variable "map_public_ip_on_launch" {
  description = "Whether to map public IP addresses on launch for public subnets"
  type        = bool
  default     = false
}

variable "nat_gateway_subnet_cidr" {
  description = "CIDR of the public subnet where NAT Gateway should be placed. If null and NAT is required, uses the first public subnet"
  type        = string
  default     = null
}

variable "cidr_all_traffic" {
  description = "CIDR block representing all internet traffic (0.0.0.0/0)"
  type        = string
  default     = "0.0.0.0/0"
}