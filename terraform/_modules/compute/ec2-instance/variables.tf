variable "create" {
  description = "Flag to create an instance"
  type        = bool
  default     = true
}

variable "name" {
  description = "Name to be used on EC2 instance"
  type        = string
  default     = ""
}

variable "tags" {
  description = "A map of tags to assign to the resource"
  type        = map(string)
  default     = {}
}

variable "ami_id" {
  description = "The AMI ID for the EC2 instance"
  type        = string
  default     = null
}

variable "ami_id_ssm_parameter" {
  description = "SSM parameter to fetch the AMI ID from"
  type        = string
  default     = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

variable "associate_public_ip_address" {
  description = "Whether to associate a public IP address with the instance"
  type        = bool
  default     = true
}

variable "instance_type" {
  description = "The instance type for the EC2 instance"
  type        = string
  default     = "t3.micro"
}

variable "availability_zone" {
  description = "AZ to start the instance"
  type        = string
  default     = null
}

variable "key_name" {
  description = "The key pair name for SSH access"
  type        = string
  default     = null
}

variable "subnet_id" {
  description = "The VPC Subnet ID to launch"
  type        = string
  default     = null
  validation {
    condition     = var.subnet_id != null
    error_message = "Subnet ID is required for EC2 instance."
  }
}

variable "vpc_security_group_ids" {
  description = "List of security group IDs to associate with the instance"
  type        = list(string)
  default     = []
}

variable "user_data" {
  description = "The user data to provide when launching the instance"
  type        = string
  default     = null
}

variable "instance_tags" {
  description = "Specific tags to add to the instance"
  type        = map(string)
  default     = {}
}

variable "root_block_device" {
  description = "Customize the root block device of the instance"
  type = object({
    delete_on_termination = optional(bool)
    volume_type           = optional(string)
    volume_size           = optional(number)
    iops                  = optional(number)
    throughput            = optional(number)
    encrypted             = optional(bool)
    kms_key_id            = optional(string)
    tags                  = optional(map(string))
  })
  default = null
}

variable "launch_template" {
  description = "Launch template to use for the instance"
  type = object({
    id      = optional(string)
    name    = optional(string)
    version = optional(string)
  })
  default = null
}
