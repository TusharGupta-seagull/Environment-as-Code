locals {
  create = var.create

  # Golden AMI first -> fallback to SSM
  ami = try(coalesce(
    var.ami_id,
    try(nonsensitive(data.aws_ssm_parameter.ami[0].value), null)
  ), null)

  # Name prefix : EAC-dev-app1 (example)
  instance_tags = merge(
    var.tags,
    var.instance_tags,
    { Name = var.name_prefix }
  )
}

# AMI Resolution
data "aws_ssm_parameter" "ami" {
  count = local.create && var.ami_id == null && var.ami_id_ssm_parameter != null ? 1 : 0
  name  = var.ami_id_ssm_parameter
}

# Launch Template
resource "aws_launch_template" "this" {
  count = local.create ? 1 : 0

  name_prefix   = "${var.name_prefix}-lt-"
  image_id      = local.ami
  instance_type = var.instance_type
  key_name      = var.key_name
  user_data     = var.user_data

  vpc_security_group_ids = var.security_group_ids

  iam_instance_profile {
    name = var.iam_instance_profile
  }

  tag_specifications {
    resource_type = "instance"
    tags          = local.instance_tags
  }

  tag_specifications {
    resource_type = "volume"
    tags          = local.instance_tags
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Autoscaling Group
resource "aws_autoscaling_group" "this" {
  count = local.create ? 1 : 0

  name                      = "${var.name_prefix}-asg"
  min_size                  = var.min_size
  max_size                  = var.max_size
  desired_capacity          = var.desired_capacity
  vpc_zone_identifier       = var.subnet_ids
  target_group_arns         = var.target_group_arns
  health_check_type         = var.health_check_type
  health_check_grace_period = var.health_check_grace_period

  launch_template {
    id      = aws_launch_template.this[0].id
    version = "$Latest"
  }

  # safe rolling replacement
  instance_refresh {
    strategy = "Rolling"

    preferences {
      min_healthy_percentage = 90
      instance_warmup        = 300
    }

    triggers = ["launch_template"]
  }

  dynamic "tag" {
    for_each = local.instance_tags
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  lifecycle {
    ignore_changes = [desired_capacity]
  }
}

# Scaling Policies and Alarms
resource "aws_autoscaling_policy" "cpu_target" {
  count = local.create ? 1 : 0

  name                   = "${var.name_prefix}-cpu-target"
  autoscaling_group_name = aws_autoscaling_group.this[0].name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value     = var.cpu_target_value
    disable_scale_in = false
  }
}

resource "aws_autoscaling_policy" "memory_scale_out" {
  count = local.create && var.enable_memory_scaling ? 1 : 0

  name                   = "${var.name_prefix}-memory-scale-out"
  autoscaling_group_name = aws_autoscaling_group.this[0].name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = 1
  cooldown               = 300
}

resource "aws_cloudwatch_metric_alarm" "memory_high" {
  count = local.create && var.enable_memory_scaling ? 1 : 0

  alarm_name          = "${var.name_prefix}-memory-high"
  namespace           = "CWAgent"
  metric_name         = "mem_used_percent"
  statistic           = "Average"
  period              = 60
  evaluation_periods  = 2
  threshold           = var.memory_high_threshold
  comparison_operator = "GreaterThanThreshold"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.this[0].name
  }

  alarm_actions = [
    aws_autoscaling_policy.memory_scale_out[0].arn
  ]
}
