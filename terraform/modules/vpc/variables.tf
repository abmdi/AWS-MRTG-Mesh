variable "vpc_cidr" {
  description = "CIDR range for the VPC"
  type        = string
}

variable "environment" {
  description = "Environment tag"
  type        = string
}

variable "name_prefix" {
  description = "Prefix for resource naming"
  type        = string
}

variable "availability_zones" {
  description = "List of Availability Zones"
  type        = list(string)
}
