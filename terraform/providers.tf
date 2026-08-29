terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Primary Region Provider
provider "aws" {
  alias  = "us_east_1"
  region = var.primary_region

  default_tags {
    tags = {
      Environment = var.environment
      Project     = "AWS-MRTG-Mesh"
      ManagedBy   = "Terraform"
    }
  }
}

# Secondary Region Provider
provider "aws" {
  alias  = "eu_west_1"
  region = var.secondary_region

  default_tags {
    tags = {
      Environment = var.environment
      Project     = "AWS-MRTG-Mesh"
      ManagedBy   = "Terraform"
    }
  }
}
