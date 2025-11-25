locals {
  alb_config = {

    # flag
    create_alb = lookup(var.alb_config, "create_alb", false)

    # settings with lookup() and defaults
    settings = {
      name = lookup(
        var.alb_config.settings, "name",
        "${local.name_prefix}-${lookup(var.alb_config.settings, "internal", false) ? "internal" : "public"}"
      )

      load_balancer_type         = lookup(var.alb_config.settings, "load_balancer_type", "application")
      internal                   = lookup(var.alb_config.settings, "internal", false)
      enable_deletion_protection = lookup(var.alb_config.settings, "enable_deletion_protection", false)
      target_port                = lookup(var.alb_config.settings, "target_port", 80)
      target_type                = lookup(var.alb_config.settings, "target_type", "instance")
      listener_port              = lookup(var.alb_config.settings, "listener_port", 80)
      protocol                   = lookup(var.alb_config.settings, "protocol", "HTTP")
      health_check_path          = lookup(var.alb_config.settings, "health_check_path", "/")
      certificate_arn            = lookup(var.alb_config.settings, "certificate_arn", null)
    }

  }
}

# Internet-facing ALB NETWORK CONFIG
module "public-alb" {
  source = "../_modules/compute/elb"
  count  = local.alb_config.create_alb ? 1 : 0


  # NETWORK CONFIG (from var.alb_network_config)
  vpc_id          = lookup(var.alb_network_config, "vpc_id", null)
  subnets         = lookup(var.alb_network_config, "subnets", [])
  security_groups = lookup(var.alb_network_config, "security_groups", [])

  # SETTINGS (lookup-safe)
  name_prefix                = lookup(local.alb_config.settings, "name", null)
  load_balancer_type         = lookup(local.alb_config.settings, "load_balancer_type", "application")
  internal                   = lookup(local.alb_config.settings, "internal", false)
  enable_deletion_protection = lookup(local.alb_config.settings, "enable_deletion_protection", false)

  # Listener / TG
  target_instance_ids = [
    for instance in module.app_instances[*] : instance.id
  ]

  target_port   = lookup(local.alb_config.settings, "target_port", 80)
  target_type   = lookup(local.alb_config.settings, "target_type", "instance")
  listener_port = lookup(local.alb_config.settings, "listener_port", 80)
  protocol      = lookup(local.alb_config.settings, "protocol", "HTTP")

  # Health check
  health_check_path = lookup(local.alb_config.settings, "health_check_path", "/")

  # SSL
  certificate_arn = lookup(local.alb_config.settings, "certificate_arn", null)

  # TAGS
  tags = merge(
    local.project_config.tags,
    {
      Component = "load-balancer"
      Type      = "application"
    }
  )

  depends_on = [module.app_instances]
}

