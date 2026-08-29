
variable "environment" {
  description = "Deployment environment name (e.g. prod, staging)"
  type        = string
  default     = "prod"
}

variable "primary_region" {
  description = "Primary AWS region for TGW deployment"
  type        = string
  default     = "us-east-1"
}

variable "secondary_region" {
  description = "Secondary AWS region for TGW deployment"
  type        = string
  default     = "eu-west-1"
}

variable "primary_vpc_cidr" {
  description = "CIDR block for Primary Region VPC"
  type        = string
  default     = "10.1.0.0/16"
}

variable "secondary_vpc_cidr" {
  description = "CIDR block for Secondary Region VPC"
  type        = string
  default     = "10.101.0.0/16"
}

variable "primary_tgw_asn" {
  description = "BGP Autonomous System Number (ASN) for Primary TGW"
  type        = number
  default     = 64512
}

variable "secondary_tgw_asn" {
  description = "BGP Autonomous System Number (ASN) for Secondary TGW"
  type        = number
  default     = 64513
}
