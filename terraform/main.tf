# Fetch Available Availability Zones for Region A
data "aws_availability_zones" "primary_az" {
  provider = aws.us_east_1
  state    = "available"
}

# Fetch Available Availability Zones for Region B
data "aws_availability_zones" "secondary_az" {
  provider = aws.eu_west_1
  state    = "available"
}

# -----------------------------------------------------------------------------
# 1. PRIMARY REGION INFRASTRUCTURE (us-east-1)
# -----------------------------------------------------------------------------

module "vpc_primary" {
  source = "./modules/vpc"

  providers = {
    aws = aws.us_east_1
  }

  name_prefix        = "${var.environment}-primary"
  environment        = var.environment
  vpc_cidr           = var.primary_vpc_cidr
  availability_zones = slice(data.aws_availability_zones.primary_az.names, 0, 2)
}

module "tgw_primary" {
  source = "./modules/tgw"

  providers = {
    aws = aws.us_east_1
  }

  name_prefix     = "${var.environment}-primary"
  amazon_side_asn = var.primary_tgw_asn
  vpc_id          = module.vpc_primary.vpc_id
  tgw_subnet_ids  = module.vpc_primary.tgw_subnet_ids
  remote_vpc_cidr = var.secondary_vpc_cidr
}

# -----------------------------------------------------------------------------
# 2. SECONDARY REGION INFRASTRUCTURE (eu-west-1)
# -----------------------------------------------------------------------------

module "vpc_secondary" {
  source = "./modules/vpc"

  providers = {
    aws = aws.eu_west_1
  }

  name_prefix        = "${var.environment}-secondary"
  environment        = var.environment
  vpc_cidr           = var.secondary_vpc_cidr
  availability_zones = slice(data.aws_availability_zones.secondary_az.names, 0, 2)
}

module "tgw_secondary" {
  source = "./modules/tgw"

  providers = {
    aws = aws.eu_west_1
  }

  name_prefix     = "${var.environment}-secondary"
  amazon_side_asn = var.secondary_tgw_asn
  vpc_id          = module.vpc_secondary.vpc_id
  tgw_subnet_ids  = module.vpc_secondary.tgw_subnet_ids
  remote_vpc_cidr = var.primary_vpc_cidr
}
# -----------------------------------------------------------------------------
# 3. INTER-REGION TGW PEERING ATTACHMENT
# -----------------------------------------------------------------------------

# Initiator: Create Peering Request from Primary Region to Secondary Region
resource "aws_ec2_transit_gateway_peering_attachment" "primary_to_secondary" {
  provider = aws.us_east_1

  transit_gateway_id      = module.tgw_primary.tgw_id
  peer_transit_gateway_id = module.tgw_secondary.tgw_id
  peer_region             = var.secondary_region

  tags = {
    Name = "${var.environment}-tgw-peering-us-east-1-eu-west-1"
  }
}

# Acceptor: Accept Peering Request in Secondary Region
resource "aws_ec2_transit_gateway_peering_attachment_accepter" "secondary_accepter" {
  provider = aws.eu_west_1

  transit_gateway_attachment_id = aws_ec2_transit_gateway_peering_attachment.primary_to_secondary.id

  tags = {
    Name = "${var.environment}-tgw-peering-accepter"
  }
}

# -----------------------------------------------------------------------------
# 4. TGW ROUTE TABLE ENTRIES FOR INTER-REGION PEERING
# -----------------------------------------------------------------------------

# Route in Primary TGW pointing to Secondary VPC CIDR via Peering Attachment
resource "aws_ec2_transit_gateway_route" "primary_to_secondary_route" {
  provider = aws.us_east_1

  destination_cidr_block         = var.secondary_vpc_cidr
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment.primary_to_secondary.id
  transit_gateway_route_table_id = module.tgw_primary.workload_route_table_id
}

# Route in Secondary TGW pointing to Primary VPC CIDR via Peering Attachment
resource "aws_ec2_transit_gateway_route" "secondary_to_primary_route" {
  provider = aws.eu_west_1

  destination_cidr_block         = var.primary_vpc_cidr
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.secondary_accepter.id
  transit_gateway_route_table_id = module.tgw_secondary.workload_route_table_id
}

# -----------------------------------------------------------------------------
# 5. VPC LOCAL ROUTE TABLE UPDATES
# -----------------------------------------------------------------------------

# Add route in Primary VPC Private Route Table towards Primary TGW
resource "aws_route" "primary_vpc_to_tgw" {
  provider = aws.us_east_1

  route_table_id         = module.vpc_primary.private_route_table_id
  destination_cidr_block = var.secondary_vpc_cidr
  transit_gateway_id     = module.tgw_primary.tgw_id
}

# Add route in Secondary VPC Private Route Table towards Secondary TGW
resource "aws_route" "secondary_vpc_to_tgw" {
  provider = aws.eu_west_1

  route_table_id         = module.vpc_secondary.private_route_table_id
  destination_cidr_block = var.primary_vpc_cidr
  transit_gateway_id     = module.tgw_secondary.tgw_id
}
