locals {
  name_prefix = "${var.project_config.project_name}-${var.project_config.env_name}"
}

variable "project_config" {
  type = any
}

variable "network_config" {
  description = "Complete network configuration including VPC, subnets, SG settings"
  type = object({
    vpc = object({
      cidr = string
    })

    subnets = object({
      public = list(object({
        cidr       = string
        avail_zone = optional(string)
      }))

      private = list(object({
        cidr             = string
        enable_nat_route = bool
        avail_zone       = optional(string)
      }))
    })

    settings = object({
      map_public_ip_on_launch = map(bool)
      create_alb              = bool
      allowed_ssh_cidr        = string
    })
  })

}
