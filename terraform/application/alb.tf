locals {
  alb_enabled = var.alb_config.create_alb

  alb_settings = {
    name                       = try(var.alb_config.settings.name, "${local.name_prefix}-alb")
    load_balancer_type         = try(var.alb_config.settings.load_balancer_type, "application")
    internal                   = try(var.alb_config.settings.internal, false)
    enable_deletion_protection = try(var.alb_config.settings.enable_deletion_protection, false)
    listener_port              = try(var.alb_config.settings.listener_port, 80)
    protocol                   = try(var.alb_config.settings.protocol, "HTTP")
    certificate_arn            = try(var.alb_config.settings.certificate_arn, null)
  }
}

module "target_groups" {
  source = "../_modules/compute/target-group"

  for_each = local.alb_enabled ? var.services : {}

  name_prefix = "${local.name_prefix}-${each.key}"
  port        = each.value.port

  vpc_id      = var.alb_network_config.vpc_id
  target_type = "instance"
  protocol    = "HTTP"

  health_check_path = each.value.health_path

  tags = merge(
    var.project_config.tags,
    {
      Service   = each.key
      Component = "target-group"
    }
  )
}


module "alb" {
  source = "../_modules/compute/elb"
  count  = local.alb_enabled ? 1 : 0

  vpc_id          = var.alb_network_config.vpc_id
  subnets         = var.alb_network_config.subnets
  security_groups = var.alb_network_config.security_groups

  name_prefix                = local.alb_settings.name
  load_balancer_type         = local.alb_settings.load_balancer_type
  internal                   = local.alb_settings.internal
  enable_deletion_protection = local.alb_settings.enable_deletion_protection

  # Listener (default → app service)
  listener_port   = local.alb_settings.listener_port
  protocol        = local.alb_settings.protocol
  certificate_arn = local.alb_settings.certificate_arn

  create_target_group = false

  # Default TG → first service (usually "app")
  target_group_arns = {
    http = {
      arn = values(module.target_groups)[0].target_group_arn
    }
  }

  tags = merge(
    var.project_config.tags,
    {
      Component = "alb"
    }
  )

  depends_on = [module.target_groups]
}

