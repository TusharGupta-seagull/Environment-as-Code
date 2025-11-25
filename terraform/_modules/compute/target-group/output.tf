output "target_group_arn" {
  description = "ARN of the target group"
  value       = aws_lb_target_group.this.arn
}

output "target_group_arn_suffix" {
  description = "ARN suffix of the target group"
  value       = aws_lb_target_group.this.arn_suffix
}

output "target_group_id" {
  description = "ID of the target group"
  value       = aws_lb_target_group.this.id
}

output "target_group_name" {
  description = "Name of the target group"
  value       = aws_lb_target_group.this.name
}

output "target_group_load_balancing_algorithm_type" {
  description = "Load balancing algorithm type"
  value       = aws_lb_target_group.this.load_balancing_algorithm_type
}

output "target_attachments" {
  description = "Map of target attachments"
  value = {
    for k, v in aws_lb_target_group_attachment.this : k => {
      id                = v.id
      target_id         = v.target_id
      port              = v.port
      availability_zone = v.availability_zone
    }
  }
}
