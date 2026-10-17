variable "vpc_name" {
  type        = string
  description = "Name of the Spoke or Hub VPC."
}

variable "cidr_block" {
  type        = string
  description = "CIDR block for the VPC."
}

variable "azs" {
  type        = list(string)
  description = "List of Availability Zones for subnets."
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "CIDR blocks for public subnets."
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "CIDR blocks for private subnets."
}

variable "tags" {
  type        = map(string)
  description = "Resource tags."
  default     = {}
}
