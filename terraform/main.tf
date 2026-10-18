# --- PRIMARY REGION (us-east-1) ---

module "vpc_primary" {
  source = "./modules/vpc"
  providers = {
    aws = aws.primary
  }
  vpc_name             = "${var.project_name}-primary-vpc"
  cidr_block           = "10.100.0.0/16"
  azs                  = ["us-east-1a", "us-east-1b"]
  public_subnet_cidrs  = ["10.100.1.0/24", "10.100.2.0/24"]
  private_subnet_cidrs = ["10.100.10.0/24", "10.100.20.0/24"]
  tags                 = var.common_tags
}

module "tgw_primary" {
  source = "./modules/tgw"
  providers = {
    aws = aws.primary
  }
  tgw_name    = "${var.project_name}-tgw-primary"
  description = "Primary Transit Gateway in US East"
  vpc_attachments = {
    "primary_vpc" = {
      vpc_id     = module.vpc_primary.vpc_id
      subnet_ids = module.vpc_primary.private_subnet_ids
    }
  }
  tags = var.common_tags
}

# --- SECONDARY REGION (eu-west-1) ---

module "vpc_secondary" {
  source = "./modules/vpc"
  providers = {
    aws = aws.secondary
  }
  vpc_name             = "${var.project_name}-secondary-vpc"
  cidr_block           = "10.200.0.0/16"
  azs                  = ["eu-west-1a", "eu-west-1b"]
  public_subnet_cidrs  = ["10.200.1.0/24", "10.200.2.0/24"]
  private_subnet_cidrs = ["10.200.10.0/24", "10.200.20.0/24"]
  tags                 = var.common_tags
}

module "tgw_secondary" {
  source = "./modules/tgw"
  providers = {
    aws = aws.secondary
  }
  tgw_name    = "${var.project_name}-tgw-secondary"
  description = "Secondary Transit Gateway in EU West"
  vpc_attachments = {
    "secondary_vpc" = {
      vpc_id     = module.vpc_secondary.vpc_id
      subnet_ids = module.vpc_secondary.private_subnet_ids
    }
  }
  tags = var.common_tags
}
