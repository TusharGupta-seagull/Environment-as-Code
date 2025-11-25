locals {
  is_alb  = var.load_balancer_type == var.elb_type["alb"]
  is_nlb  = var.load_balancer_type == var.elb_type["nlb"]
  is_gwlb = var.load_balancer_type == var.elb_type["gwlb"]

  name_prefix = var.name_prefix

  # Determine protocol based on load balancer type
  protocol = local.is_gwlb ? "GENEVE" : var.protocol

  # Health check enabled for ALB and NLB only
  enable_health_check = !local.is_gwlb
}

resource "aws_lb_target_group" "this" {
  name        = var.name != "" ? var.name : "${var.name_prefix}-tg"
  port        = var.port
  protocol    = local.protocol
  vpc_id      = var.vpc_id
  target_type = var.target_type

  deregistration_delay               = var.deregistration_delay
  connection_termination             = var.connection_termination
  preserve_client_ip                 = var.preserve_client_ip
  proxy_protocol_v2                  = var.proxy_protocol_v2
  slow_start                         = var.slow_start
  lambda_multi_value_headers_enabled = var.lambda_multi_value_headers_enabled
  load_balancing_algorithm_type      = var.load_balancing_algorithm_type
  ip_address_type                    = var.ip_address_type

  dynamic "health_check" {
    for_each = local.enable_health_check ? [1] : []
    content {
      enabled             = var.health_check_enabled
      path                = local.is_alb || var.protocol == "HTTP" || var.protocol == "HTTPS" ? var.health_check_path : null
      port                = var.health_check_port
      protocol            = var.health_check_protocol != "" ? var.health_check_protocol : var.protocol
      interval            = var.health_check_interval
      timeout             = var.health_check_timeout
      healthy_threshold   = var.health_check_healthy_threshold
      unhealthy_threshold = var.health_check_unhealthy_threshold
      matcher             = local.is_alb || var.protocol == "HTTP" || var.protocol == "HTTPS" ? var.health_check_matcher : null
    }
  }

  dynamic "stickiness" {
    for_each = var.stickiness_enabled ? [1] : []
    content {
      enabled         = true
      type            = var.stickiness_type
      cookie_duration = var.stickiness_cookie_duration
      cookie_name     = var.stickiness_cookie_name != "" ? var.stickiness_cookie_name : null
    }
  }

  dynamic "target_failover" {
    for_each = length(var.target_failover) > 0 ? [var.target_failover] : []
    content {
      on_deregistration = lookup(target_failover.value, "on_deregistration", null)
      on_unhealthy      = lookup(target_failover.value, "on_unhealthy", null)
    }
  }

  dynamic "target_health_state" {
    for_each = length(var.target_health_state) > 0 ? [var.target_health_state] : []
    content {
      enable_unhealthy_connection_termination = lookup(target_health_state.value, "enable_unhealthy_connection_termination", true)
    }
  }

  tags = merge(
    var.tags,
    {
      "Name" = var.name != "" ? var.name : "${var.name_prefix}-tg"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_target_group_attachment" "this" {
  for_each = var.targets

  target_group_arn  = aws_lb_target_group.this.arn
  target_id         = each.value.target_id
  port              = lookup(each.value, "port", var.port)
  availability_zone = lookup(each.value, "availability_zone", null)
}
