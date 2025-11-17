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

variable "ec2_config" {
  type = object({
    bastion = object({
      subnet_id = string
      sg_ids    = list(string)
      count     = number
    })

    app = object({
      subnet_id = string
      sg_ids    = list(string)
      count     = number
      user_data = optional(string)
    })

    db = object({
      subnet_id = string
      sg_ids    = list(string)
      count     = number

    })
    key_name = string
  })
  default = {
    bastion = {
      subnet_id = "" 
      sg_ids    = [] 
      count     = 1  

    }

    app = {
      subnet_id = "" 
      sg_ids    = [] 
      count     = 2  
      user_data = ""
    }

    db = {
      subnet_id = "" 
      sg_ids    = []
      count     = 1 
    }

    key_name = ""
  }
}

# ALB 
variable "create_alb" {
  description = "Whether to create an Application Load Balancer"
  type        = bool
  default     = true
}

variable "alb_config" {
  description = "Settings and infrastructure inputs for ALB"

  type = object({
    settings = object({
      name                       = optional(string)
      load_balancer_type         = optional(string)
      internal                   = optional(bool)
      enable_deletion_protection = optional(bool)

      target_port = optional(number)
      target_type = optional(string)

      listener_port = optional(number)
      protocol      = optional(string)

      health_check_path     = optional(string)
      health_check_port     = optional(string)
      health_check_protocol = optional(string)

      idle_timeout    = optional(number)
      certificate_arn = optional(string)
    })

    infra = object({
      vpc_id          = string
      subnets         = list(string)
      security_groups = list(string)
    })
  })

  default = {
    settings = {
      name                       = null
      load_balancer_type         = "application"
      internal                   = false
      enable_deletion_protection = false
      target_port = 80
      target_type = "instance"
      listener_port = 80
      protocol      = "HTTP"
      health_check_path     = "/"
      certificate_arn = ""
    }

    infra = {
      vpc_id          = ""
      subnets         = []
      security_groups = []
      target_instance_ids=[]
      user_data = ""
    }
  }
}
