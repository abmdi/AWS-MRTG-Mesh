# 1. AWS Transit Gateway Core
resource "aws_ec2_transit_gateway" "tgw" {
  description                     = var.description
  dns_support                     = "enable"
  vpn_ecmp_support                = "enable"
  default_route_table_association = "enable"
  default_route_table_propagation = "enable"

  tags = merge(var.tags, {
    Name = var.tgw_name
  })
}

# 2. Transit Gateway VPC Attachments
resource "aws_ec2_transit_gateway_vpc_attachment" "attachments" {
  for_each = var.vpc_attachments

  transit_gateway_id                              = aws_ec2_transit_gateway.tgw.id
  vpc_id                                          = each.value.vpc_id
  subnet_ids                                      = each.value.subnet_ids
  dns_support                                     = each.value.dns_support
  ipv6_support                                    = each.value.ipv6_support
  transit_gateway_default_route_table_association = each.value.transit_gateway_default_route_table_association
  transit_gateway_default_route_table_propagation = each.value.transit_gateway_default_route_table_propagation

  tags = merge(var.tags, {
    Name = "${var.tgw_name}-attachment-${each.key}"
  })
}
