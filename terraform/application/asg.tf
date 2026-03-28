module "asg" {
  source = "../_modules/compute/autoscaling"

  for_each    = var.services
  name_prefix = "${local.name_prefix}-${each.key}"

  # Capacity
  min_size         = each.value.min
  max_size         = each.value.max
  desired_capacity = each.value.desired

  # Launch template inputs
  instance_type = each.value.instance_type
  ami_id        = each.value.ami_id
  key_name      = var.ec2_config.key_name
  user_data     = try(each.value.user_data, null)

  subnet_ids         = var.ec2_network_config.app.subnet_ids
  security_group_ids = var.ec2_network_config.app.sg_ids

  target_group_arns = [
    module.target_groups[each.key].target_group_arn
  ]

  # Health checks MUST come from ALB
  health_check_type         = "ELB"
  health_check_grace_period = 120

  tags = merge(
    var.project_config.tags,
    {
      Service   = each.key
      Component = "asg"
    }
  )

  depends_on = [
    module.target_groups,
    module.alb
  ]
}
