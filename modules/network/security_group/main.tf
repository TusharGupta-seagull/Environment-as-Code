locals {
  create_sg = var.create_sg

  tags = merge(
    var.tags,
    var.sg_tags,
    var.sg_name != null ? { Name = var.sg_name } : {}
  )
}

resource "aws_security_group" "main" {
  count = local.create_sg ? 1 : 0

  name        = var.sg_name != null ? var.sg_name : "default-sg"
  description = var.sg_description != null ? var.sg_description : "default-sg"
  vpc_id      = var.sg_vpc_id

  tags = local.tags
}

resource "aws_vpc_security_group_ingress_rule" "this" {
  for_each = local.create_sg && var.sg_ingress_rules != null ? var.sg_ingress_rules : {}

  security_group_id = aws_security_group.main[0].id

  cidr_ipv4                    = each.value.cidr_ipv4
  from_port                    = each.value.from_port
  to_port                      = each.value.to_port
  ip_protocol                  = each.value.ip_protocol
  description                  = each.value.description
  prefix_list_id               = each.value.prefix_list_id
  referenced_security_group_id = each.value.referenced_security_group_id
  tags                         = each.value.tags

}

resource "aws_vpc_security_group_egress_rule" "this" {
  for_each = local.create_sg && length(var.sg_egress_rules) > 0 ? var.sg_egress_rules : {}

  security_group_id = aws_security_group.main[0].id

  cidr_ipv4                    = each.value.cidr_ipv4
  from_port                    = each.value.from_port
  to_port                      = each.value.to_port
  ip_protocol                  = each.value.ip_protocol
  description                  = each.value.description
  prefix_list_id               = each.value.prefix_list_id
  referenced_security_group_id = each.value.referenced_security_group_id
  tags                         = each.value.tags
}
