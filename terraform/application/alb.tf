module "alb" {
  source = "../_modules/compute/elb"
  count  = var.create_alb ? 1 : 0

  vpc_id          = var.alb_config.infra.vpc_id
  subnets         = var.alb_config.infra.subnets
  security_groups = var.alb_config.infra.security_groups

  name                       = lookup(var.alb_config.settings, "name", "${var.project_name}-${var.env_name}-alb")
  load_balancer_type         = lookup(var.alb_config.settings, "load_balancer_type", "application")
  internal                   = lookup(var.alb_config.settings, "internal", false)
  enable_deletion_protection = lookup(var.alb_config.settings, "enable_deletion_protection", false)

  # Listener + TG
  target_instance_ids = [
    for instance in module.app_instances[*] : instance.id
  ]
  target_port   = lookup(var.alb_config.settings, "target_port", 80)
  target_type   = lookup(var.alb_config.settings, "target_type", "instance")
  listener_port = lookup(var.alb_config.settings, "listener_port", 80)
  protocol      = lookup(var.alb_config.settings, "protocol", "HTTP")

  # Health check
  health_check_path = lookup(var.alb_config.settings, "health_check_path", "/")

  # SSL
  certificate_arn = lookup(var.alb_config.settings, "certificate_arn", null)
  
  # Tags
  tags = merge(var.tags, {
    Component = "load-balancer"
    Type      = "application"
  })
  depends_on = [module.app_instances]
}



