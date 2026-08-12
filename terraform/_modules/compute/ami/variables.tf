variable "ami_id" {
  description = "Golden AMI ID (highest priority)"
  type        = string
  default     = null
}

variable "ami_id_ssm_parameter" {
  description = "SSM parameter name for fallback AMI resolution"
  type        = string
  default     = null
}
