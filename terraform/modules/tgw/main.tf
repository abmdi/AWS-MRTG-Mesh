
# AWS Transit Gateway Resource
resource "aws_ec2_transit_gateway" "main" {
  description                     = "Production TGW for ${var.name_prefix}"
  amazon_side_asn                 = var.amazon_side_asn
  default_route_table_association = "disable"
  default_route_table_propagation = "disable"
  dns_support                     = "enable"
  vpn_ecmp_support                = "enable"

  tags = {
    Name = "${var.name_prefix}-tgw"
  }
}

# TGW VPC Attachment
resource "aws_ec2_transit_gateway_vpc_attachment" "main" {
  transit_gateway_id = aws_ec2_transit_gateway.main.id
  vpc_id             = var.vpc_id
  subnet_ids         = var.tgw_subnet_ids

  dns_support = "enable"

  tags = {
    Name = "${var.name_prefix}-tgw-attachment"
  }
}
