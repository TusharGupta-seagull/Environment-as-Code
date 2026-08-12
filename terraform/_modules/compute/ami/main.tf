# Resolves the AMI for compute resources:
#   1. golden AMI (var.ami_id) when provided
#   2. otherwise the value of the SSM parameter (var.ami_id_ssm_parameter)
# Shared by the ec2-instance (bastion) and autoscaling modules:
#   - bastion host:      Amazon Linux AL2023 via the SSM parameter (never the golden image)
#   - ASG launch template: golden AMI only (the caller does not pass an SSM parameter)
data "aws_ssm_parameter" "ami" {
  count = var.ami_id == null && var.ami_id_ssm_parameter != null ? 1 : 0
  name  = var.ami_id_ssm_parameter
}

locals {
  resolved_ami_id = try(coalesce(
    var.ami_id,
    try(nonsensitive(data.aws_ssm_parameter.ami[0].value), null)
  ), null)
}
