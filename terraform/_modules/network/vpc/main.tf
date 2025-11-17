# LOCALS.
locals {
  priv_nat_connected_subnet = [for subnet in var.priv_cidrs : subnet.cidr if subnet.enable_nat_route]
  nat_required              = length(local.priv_nat_connected_subnet) > 0

  nat_subnet_cidr = local.nat_required ? (
    var.nat_gateway_subnet_cidr != null ? var.nat_gateway_subnet_cidr : var.pub_cidrs[0].cidr
  ) : null

  priv_subnets_with_nat = local.nat_required ? local.priv_nat_connected_subnet : []
  priv_subnets_isolated = [for s in var.priv_cidrs : s.cidr if !s.enable_nat_route || !local.nat_required]
}

# VPC configurations ----------------------------------------------------
resource "aws_vpc" "this" {
  cidr_block = var.vpc_cidr

  tags = merge(var.tags, {
    "Name" = "${var.project_name}-${var.env_name}-vpc"
  })
}

# IGW --------------------------------------------------------
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.this.id

  tags = {
    "Name" = "${var.project_name}-${var.env_name}-igw"
  }
}

# Nat gtw -------------------------------------------------------

resource "aws_eip" "nat_eip" {
  count  = local.nat_required ? 1 : 0
  domain = "vpc"
}

resource "aws_nat_gateway" "nat" {
  count = local.nat_required ? 1 : 0

  allocation_id = aws_eip.nat_eip[0].id
  subnet_id     = aws_subnet.pub_sub[local.nat_subnet_cidr].id

  depends_on = [aws_internet_gateway.igw]

  tags = merge(var.tags, {
    "Name" = "${var.project_name}-${var.env_name}-nat"
  })
}

# Subnets ---------------------------------------------------------
#public subnets
resource "aws_subnet" "pub_sub" {
  for_each = { for subnet in var.pub_cidrs : subnet.cidr => subnet }

  vpc_id            = aws_vpc.this.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.avail_zone

  map_public_ip_on_launch = var.map_public_ip_on_launch.pub_sub

  tags = {
    "Name" = "${var.project_name}-${var.env_name}-pub-${each.key}"
  }
}

#private subnets
resource "aws_subnet" "priv_sub" {
  for_each = { for subnet in var.priv_cidrs : subnet.cidr => subnet }

  vpc_id                  = aws_vpc.this.id
  cidr_block              = each.value.cidr
  availability_zone       = each.value.avail_zone
  map_public_ip_on_launch = var.map_public_ip_on_launch.priv_sub

  tags = {
    "Name" = "${var.project_name}-${var.env_name}-priv-${each.key}"
  }
}

# Route tables -----------------------------------------------------------
# Public subnet - rt
resource "aws_route_table" "pub_rt" {
  vpc_id = aws_vpc.this.id

  route {
    gateway_id = aws_internet_gateway.igw.id
    cidr_block = var.cidr_all_traffic
  }

  depends_on = [aws_internet_gateway.igw]

  tags = merge(var.tags, {
    "Name" = "${var.project_name}-${var.env_name}-pub-rt"
  })
}

# Private subnet - rt - isolated
resource "aws_route_table" "priv_rt_isolated" {
  count = length(local.priv_subnets_isolated) > 0 ? 1 : 0

  vpc_id = aws_vpc.this.id

  # NO INTERNET TRAFFIC

  tags = merge(var.tags, {
    "Name" = "${var.project_name}-${var.env_name}-priv-rt-isolated"
  })
}

# private subnet - rt - NAT connected 
resource "aws_route_table" "priv_rt_nat" {
  count = length(local.priv_subnets_with_nat) > 0 ? 1 : 0

  vpc_id = aws_vpc.this.id

  route {
    cidr_block = var.cidr_all_traffic
    gateway_id = aws_nat_gateway.nat[0].id
  }

  depends_on = [aws_nat_gateway.nat]

  tags = merge(var.tags, {
    "Name" = "${var.project_name}-${var.env_name}-priv-rt-nat"
  })
}

# Route tables associations --------------------------------------------------

# Public subnet assoc
resource "aws_route_table_association" "pub_rt_assoc" {
  for_each = aws_subnet.pub_sub

  subnet_id      = each.value.id
  route_table_id = aws_route_table.pub_rt.id
}

# Private subnet - NAT connected assoc
resource "aws_route_table_association" "priv_rt_nat_assoc" {
  for_each = toset(local.priv_subnets_with_nat)

  subnet_id      = aws_subnet.priv_sub[each.value].id
  route_table_id = aws_route_table.priv_rt_nat[0].id
}

# Private subnet - isolated assoc
resource "aws_route_table_association" "priv_rt_isolated_assoc" {

  for_each = toset(local.priv_subnets_isolated)

  subnet_id      = aws_subnet.priv_sub[each.value].id
  route_table_id = aws_route_table.priv_rt_isolated[0].id
}

# NACL-----------------------------------------------------------------
# To be added soon!
