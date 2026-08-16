# Root Module - output.tf

# Deployment Summary
output "deployment_summary" {
  description = "Comprehensive deployment summary"
  value = {
    project = var.project_config
    infrastructure = {
      vpc_id          = module.network.vpc.id
      public_subnets  = length(module.network.subnets.public.ids)
      private_subnets = length(module.network.subnets.private.ids)
      bastion_hosts   = length(module.application.bastion_instances)
      asg_count       = length(module.application.autoscaling_groups)
      db_servers      = try(module.database.rds.enabled ? 1 : 0, 0)
      load_balancer   = var.alb_config.create_alb ? "Enabled" : "Disabled"
    }
    connectivity = {
      bastion_public_ip      = try(module.application.bastion_instances[0].public_ip, null)
      load_balancer_DNS_name = try(module.application.load_balancer.dns_name, null)
      alb_dns_name           = try(module.application.load_balancer.dns_name, null)
    }
    security = {
      ssh_key_name     = try(aws_key_pair.ansible_key[0].key_name, var.ssh_key_pair_name)
      allowed_ssh_cidr = var.network_config.settings.allowed_ssh_cidr
    }
  }
}
