
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

# Custom TGW Route Table for Workloads
resource "aws_ec2_transit_gateway_route_table" "workload_rt" {
  transit_gateway_id = aws_ec2_transit_gateway.main.id

  tags = {
    Name = "${var.name_prefix}-workload-tgw-rt"
  }
}

# Custom TGW Route Table for Inter-Region Peering
resource "aws_ec2_transit_gateway_route_table" "peering_rt" {
  transit_gateway_id = aws_ec2_transit_gateway.main.id

  tags = {
    Name = "${var.name_prefix}-peering-tgw-rt"
  }
}

# TGW Route Table Association
resource "aws_ec2_transit_gateway_route_table_association" "workload_assoc" {
  transit_gateway_attachment_id = aws_ec2_transit_gateway_vpc_attachment.main.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.workload_rt.id
}

# TGW Route Table Propagation
resource "aws_ec2_transit_gateway_route_table_propagation" "workload_prop" {
  transit_gateway_attachment_id = aws_ec2_transit_gateway_vpc_attachment.main.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.workload_rt.id
}
