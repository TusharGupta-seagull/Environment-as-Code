output "asg_name" {
  value = aws_autoscaling_group.this[0].name
}

output "asg_arn" {
  value = aws_autoscaling_group.this[0].arn
}

output "asg_id" {
  value = aws_autoscaling_group.this[0].id
}

output "launch_template_id" {
  value = aws_launch_template.this[0].id
}

output "launch_template_arn" {
  value = aws_launch_template.this[0].arn
}

output "launch_template_latest_version" {
  value = aws_launch_template.this[0].latest_version
}

output "cpu_scaling_policy_arn" {
  value = aws_autoscaling_policy.cpu_target[0].arn
}

output "memory_scaling_policy_arn" {
  value = try(aws_autoscaling_policy.memory_scale_out[0].arn, null)
}

output "memory_alarm_name" {
  value = try(aws_cloudwatch_metric_alarm.memory_high[0].alarm_name, null)
}

output "resolved_ami_id" {
  value = module.ami.resolved_ami_id
}
