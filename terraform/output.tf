# # Root Module - output.tf

# Deployment Summary
output "deployment_summary" {
  description = "Comprehensive deployment summary"
  value = {
    project = local.project_config
    infrastructure = {
      vpc_id          = module.network.vpc.id
      public_subnets  = length(module.network.subnets.public)
      private_subnets = length(module.network.subnets.private)
      bastion_hosts   = length(module.application_instances.bastion_instances)
      app_servers     = length(module.application_instances.app_instances)
      db_servers      = length(module.database)
      load_balancer   = var.alb_config.create_alb ? "Enabled" : "Disabled"
    }
    connectivity = {
      bastion_public_ip      = try(module.application_instances.bastion_instances[0].public_ip, null)
      load_balancer_DNS_name = try(module.application_instances.load_balancer.dns_name, null)
      alb_dns_name           = try(module.application_instances.alb.alb_dns_name, null)
    }
    security = {
      ssh_key_name     = aws_key_pair.ansible_key.key_name
      allowed_ssh_cidr = var.network_config.settings.allowed_ssh_cidr
    }
  }
}
