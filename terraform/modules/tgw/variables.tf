variable "name_prefix" {
  description = "Prefix for TGW resource naming"
  type        = string
}

variable "amazon_side_asn" {
  description = "BGP Autonomous System Number (ASN) for the Transit Gateway"
  type        = number
  default     = 64512
}
