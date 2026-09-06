variable "name_prefix" {
  description = "Prefix for TGW resource naming"
  type        = string
}

variable "amazon_side_asn" {
  description = "BGP Autonomous System Number (ASN) for the Transit Gateway"
  type        = number
  default     = 64512
}

variable "vpc_id" {
  description = "Target VPC ID for TGW Attachment"
  type        = string
}

variable "tgw_subnet_ids" {
  description = "List of TGW dedicated subnet IDs within the VPC"
  type        = list(string)
}

variable "remote_vpc_cidr" {
  description = "Destination VPC CIDR block for static peering routing"
  type        = string
}
