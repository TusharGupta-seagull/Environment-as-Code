variable "project_name" {
  type    = string
  default = "Seagulls-vpc"
}

variable "env_name" {
  type    = string
  default = "dev"
}


variable "tags" {
  description = "Common tags for all the VPC resources"
  type        = map(string)
  default     = {}
}

variable "aws_region" {
  type    = string
  default = "ap-south-1"

}

variable "vpc_cidr" {
  description = "stage VPC cidr"
  type        = string
  default     = "10.0.0.0/16"
}




variable "pub_cidrs" {
  type    = list(string)
  default = ["10.0.1.0/24"]
}

variable "priv_cidrs" {
  type    = list(string)
  default = []
}

locals {
  nat_subnet_cidr = length(var.pub_cidrs) > 0 ? var.pub_cidrs[0] : null
}

variable "pub_az" {
  type    = string
  default = "ap-south-1a"
}

variable "priv_az" {
  type    = string
  default = "ap-south-1b"
}

variable "cidr_all_traffic" {
  type    = string
  default = "0.0.0.0/0"
}

