locals {
  project_config = var.project_config
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

  default = {
    vpc = {
      cidr = "10.0.0.0/16"
    }

    subnets = {
      public = [
        {
          cidr       = "10.0.1.0/24"
          avail_zone = "us-east-1a"
        },
        {
          cidr       = "10.0.2.0/24"
          avail_zone = "us-east-1b"
        }
      ]

      private = [
        {
          cidr             = "10.0.10.0/24"
          enable_nat_route = true
          avail_zone       = "us-east-1b"
        }
      ]
    }

    settings = {
      map_public_ip_on_launch = {
        pub_sub  = true
        priv_sub = false
      }
      create_alb       = true
      allowed_ssh_cidr = "0.0.0.0/0"
    }
  }
}
