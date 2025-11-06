
# ============================================
# VPC Outputs
# ============================================

output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.this.id
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = aws_vpc.this.cidr_block
}

output "vpc_name" {
  description = "Name of the VPC"
  value       = aws_vpc.this.tags["Name"]
}

# ============================================
# Public Subnet Outputs
# ============================================

output "public_subnet_ids" {
  description = "List of IDs of public subnets"
  value       = [for subnet in aws_subnet.pub_sub : subnet.id]
}

output "public_subnet_cidrs" {
  description = "List of CIDR blocks of public subnets"
  value       = [for subnet in aws_subnet.pub_sub : subnet.cidr_block]
}

output "public_subnet_map" {
  description = "Map of public subnet CIDRs to their IDs"
  value       = { for k, subnet in aws_subnet.pub_sub : k => subnet.id }
}

output "public_subnet_availability_zones" {
  description = "Map of public subnet CIDRs to their availability zones"
  value       = { for k, subnet in aws_subnet.pub_sub : k => subnet.availability_zone }
}

# ============================================
# Private Subnet Outputs
# ============================================

output "private_subnet_ids" {
  description = "List of IDs of private subnets"
  value       = [for subnet in aws_subnet.priv_sub : subnet.id]
}

output "private_subnet_arns" {
  description = "List of ARNs of private subnets"
  value       = [for subnet in aws_subnet.priv_sub : subnet.arn]
}

output "private_subnet_cidrs" {
  description = "List of CIDR blocks of private subnets"
  value       = [for subnet in aws_subnet.priv_sub : subnet.cidr_block]
}

output "private_subnet_map" {
  description = "Map of private subnet CIDRs to their IDs"
  value       = { for k, subnet in aws_subnet.priv_sub : k => subnet.id }
}

output "private_subnet_availability_zones" {
  description = "Map of private subnet CIDRs to their availability zones"
  value       = { for k, subnet in aws_subnet.priv_sub : k => subnet.availability_zone }
}

# ============================================
# Private Subnet Categorization
# ============================================

output "private_subnets_with_nat_ids" {
  description = "List of IDs of private subnets with NAT Gateway access"
  value       = [for cidr in local.priv_subnets_with_nat : aws_subnet.priv_sub[cidr].id]
}

output "private_subnets_isolated_ids" {
  description = "List of IDs of isolated private subnets"
  value       = [for cidr in local.priv_subnets_isolated : aws_subnet.priv_sub[cidr].id]
}

# ============================================
# Internet Gateway Outputs
# ============================================

output "internet_gateway_id" {
  description = "The ID of the Internet Gateway"
  value       = aws_internet_gateway.igw.id
}

# ============================================
# NAT Gateway Outputs
# ============================================

output "nat_gateway_enabled" {
  description = "Whether NAT Gateway is enabled"
  value       = local.nat_required
}

output "nat_gateway_id" {
  description = "The ID of the NAT Gateway (empty if not created)"
  value       = local.nat_required ? aws_nat_gateway.nat[0].id : null
}

output "nat_gateway_subnet_cidr" {
  description = "CIDR of the public subnet hosting the NAT Gateway"
  value       = local.nat_subnet_cidr
}

output "nat_gateway_public_ip" {
  description = "The public IP address of the NAT Gateway"
  value       = local.nat_required ? aws_eip.nat_eip[0].public_ip : null
}

# ============================================
# Route Table Outputs
# ============================================

# Public route table
output "public_route_table" {
  description = "Public route table details"
  value = {
    id   = aws_route_table.pub_rt.id
    name = aws_route_table.pub_rt.tags["Name"]
  }
}

# Private route table with NAT Gateway route (if any)
output "private_route_table_nat" {
  description = "Private route table with NAT Gateway route (if created)"
  value = length(aws_route_table.priv_rt_nat) > 0 ? {
    id   = aws_route_table.priv_rt_nat[0].id
    name = aws_route_table.priv_rt_nat[0].tags["Name"]
  } : null
}

# Isolated private route table (no NAT)
output "private_route_table_isolated" {
  description = "Isolated private route table (no NAT)"
  value = length(aws_route_table.priv_rt_isolated) > 0 ? {
    id   = aws_route_table.priv_rt_isolated[0].id
    name = aws_route_table.priv_rt_isolated[0].tags["Name"]
  } : null
}

# ============================================
# Network Summary
# ============================================

output "network_summary" {
  description = "Summary of the VPC network configuration"
  value = {
    vpc_id                   = aws_vpc.this.id
    vpc_cidr                 = aws_vpc.this.cidr_block
    public_subnet_count      = length(aws_subnet.pub_sub)
    private_subnet_count     = length(aws_subnet.priv_sub)
    nat_enabled              = local.nat_required
    private_subnets_with_nat = length(local.priv_subnets_with_nat)
    private_subnets_isolated = length(local.priv_subnets_isolated)
  }
}

# ============================================
# Availability Zones
# ============================================

output "availability_zones_used" {
  description = "List of availability zones used by subnets"
  value = distinct(concat(
    [for subnet in aws_subnet.pub_sub : subnet.availability_zone],
    [for subnet in aws_subnet.priv_sub : subnet.availability_zone]
  ))
}