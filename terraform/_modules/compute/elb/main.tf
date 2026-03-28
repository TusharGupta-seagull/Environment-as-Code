locals {
  is_alb  = var.load_balancer_type == var.elb_type["alb"]
  is_nlb  = var.load_balancer_type == var.elb_type["nlb"]
  is_gwlb = var.load_balancer_type == var.elb_type["gwlb"]

  http_target_group_arn = var.create_target_group ? aws_lb_target_group.http[0].arn : var.target_groups.http.target_group_arn

  https_target_group_arn = var.create_target_group ? aws_lb_target_group.https[0].arn : var.target_groups.https.target_group_arn
}

resource "aws_lb" "this" {
  name               = "${var.name_prefix}-lb"
  internal           = var.internal
  load_balancer_type = var.load_balancer_type
  subnets            = var.subnets
  security_groups    = local.is_alb ? var.security_groups : null

  enable_deletion_protection = var.enable_deletion_protection
  drop_invalid_header_fields = local.is_alb ? true : null

  tags = merge(var.tags, {
    "Name" = "${var.name_prefix}-lb"
  })
}

resource "aws_lb_target_group" "this" {
  count = var.create_target_group ? 1 : 0

  name        = "${var.name_prefix}-tg"
  port        = var.target_port
  protocol    = local.is_gwlb ? "GENEVE" : var.protocol
  vpc_id      = var.vpc_id
  target_type = var.target_type

  dynamic "health_check" {
    for_each = local.is_gwlb ? [] : [1]
    content {
      path                = local.is_alb ? var.health_check_path : null
      interval            = 20
      timeout             = 5
      healthy_threshold   = 5
      unhealthy_threshold = 2
      matcher             = local.is_alb ? "200-399" : null
    }
  }

  tags = merge(
    var.tags,
    { "Name" = "${var.name_prefix}-tg" }
  )
}

resource "aws_lb_listener" "http" {
  count             = local.is_alb || local.is_nlb ? 1 : 0
  load_balancer_arn = aws_lb.this.arn
  port              = var.listener_port
  protocol          = var.protocol

  default_action {
    type             = "forward"
    target_group_arn = local.http_target_group_arn
  }
}

resource "aws_lb_listener" "https" {
  count             = local.is_alb && var.certificate_arn != "" ? 1 : 0
  load_balancer_arn = aws_lb.this.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = local.https_target_group_arn
  }
}

# Not required for ASG since it can register targets directly
# resource "aws_lb_target_group_attachment" "this" {
#   count = var.create_target_group && !local.is_gwlb ? length(var.target_instance_ids) : 0

#   target_group_arn = aws_lb_target_group.this[0].arn
#   target_id        = var.target_instance_ids[count.index]
#   port             = var.target_port
# }
