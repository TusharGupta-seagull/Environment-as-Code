module "asg" {
  source = "../_modules/compute/autoscaling"

  for_each    = var.services
  name_prefix = "${local.name_prefix}-${each.key}"

  # Capacity
  min_size         = each.value.min_size
  max_size         = each.value.max_size
  desired_capacity = each.value.desired

  # Launch template inputs — the ASG launch template uses the golden image ONLY
  # (services[].ami_id is required; there is no SSM/bare-AL2023 fallback here).
  instance_type        = each.value.instance_type
  ami_id               = each.value.ami_id
  key_name             = var.ec2_config.key_name
  user_data            = try(each.value.user_data, null)
  iam_instance_profile = try(each.value.iam_instance_profile, null)

  subnet_ids         = var.ec2_network_config.app.subnet_ids
  security_group_ids = var.ec2_network_config.app.sg_ids

  # Target groups only exist when the ALB is enabled
  target_group_arns = var.alb_config.create_alb ? [module.target_groups[each.key].target_group_arn] : []

  # Health checks come from the ALB when enabled, otherwise EC2
  health_check_type         = var.alb_config.create_alb ? "ELB" : "EC2"
  health_check_grace_period = var.alb_config.create_alb ? 90 : 0

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
