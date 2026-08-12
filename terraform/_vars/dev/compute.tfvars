## 1. EC2_CONFIG
## 2. ALB_CONFIG

# -----------------------------------------------------------------------------------------

# 1. EC2_CONFIG
ec2_config = {
  bastion = {
    count         = 1
    instance_type = "t3.micro"

    # AMI is NOT configurable: the bastion always runs Amazon Linux (AL2023 via SSM).
    # The golden image is reserved exclusively for the ASG launch template (see services.tfvars).
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

    listener_port = 80
    protocol      = "HTTP"

    certificate_arn = ""
  }
}
