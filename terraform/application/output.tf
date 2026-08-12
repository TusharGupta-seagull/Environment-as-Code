# EC2 Instances
output "bastion_instances" {
  description = "Bastion host instance details"
  value = {
    for idx, instance in module.bastion_instances : idx => {
      id            = instance.id
      public_ip     = instance.public_ip
      private_ip    = instance.private_ip
      instance_type = instance.instance_type
      az            = instance.availability_zone
      state         = instance.instance_state
    }
  }
}

# Autoscaling Groups
output "autoscaling_groups" {
  description = "ASG details per service"
  value = {
    for name, asg in module.asg : name => {
      asg_name               = asg.asg_name
      launch_template_id     = asg.launch_template_id
      resolved_ami_id        = asg.resolved_ami_id
      cpu_scaling_policy_arn = asg.cpu_scaling_policy_arn
    }
  }
}

# Application Load Balancer
output "load_balancer" {
  description = "Application Load Balancer details"
  value = {
    enabled          = var.alb_config.create_alb
    arn              = try(module.alb[0].lb_arn, null)
    dns_name         = try(module.alb[0].lb_dns_name, null)
    zone_id          = try(module.alb[0].lb_zone_id, null)
    arn_suffix       = try(module.alb[0].lb_arn_suffix, null)
    target_group_arn = try(module.alb[0].target_group_arn, null)
    url              = try("http://${module.alb[0].lb_dns_name}", null)
    https_url        = try(var.alb_config.certificate_arn != null ? "https://${module.alb[0].lb_dns_name}" : null, null)
  }
}
