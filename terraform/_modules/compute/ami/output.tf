output "resolved_ami_id" {
  description = "Resolved AMI ID: golden AMI if provided, otherwise the SSM parameter value"
  value       = local.resolved_ami_id
}
