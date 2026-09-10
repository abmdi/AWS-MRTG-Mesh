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
