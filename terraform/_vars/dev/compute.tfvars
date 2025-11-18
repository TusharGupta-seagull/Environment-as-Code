## 1. EC2_CONFIG
## 2. ALB_CONFIG

# -----------------------------------------------------------------------------------------

# 1. EC2_CONFIG
ec2_config = {
  bastion = {
    count         = 1
    instance_type = "t3.micro"

    ami_id                      = null
    user_data                   = null
    availability_zone           = null
    associate_public_ip_address = true

    root_block_device = {
      delete_on_termination = true
      volume_type           = "gp3"
      volume_size           = 10
      encrypted             = true
    }
  }

  app = {
    count         = 2
    instance_type = "t3.micro"

    ami_id                      = null
    user_data                   = null
    availability_zone           = null
    associate_public_ip_address = false

    root_block_device = {
      delete_on_termination = true
      volume_type           = "gp3"
      volume_size           = 10
      encrypted             = true
    }
  }

  db = {
    count         = 0
    instance_type = "t3.micro"

    ami_id                      = null
    user_data                   = null
    availability_zone           = null
    associate_public_ip_address = false

    root_block_device = {
      delete_on_termination = true
      volume_type           = "gp3"
      volume_size           = 10
      encrypted             = true
    }
  }
  key_name = "eac-dev-key"
}

# ----------------------------------------------------------------------------------------

# 2. ALB_CONFIG
alb_config = {
  create_alb = true

  settings = {
    name                       = "myapp-dev-alb"
    load_balancer_type         = "application"
    internal                   = false
    enable_deletion_protection = false

    target_port   = 80
    target_type   = "instance"
    listener_port = 80
    protocol      = "HTTP"

    health_check_path = "/"
    certificate_arn   = ""
  }
}
