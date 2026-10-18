variable "tgw_name" {
  type        = string
  description = "Name tag for the Transit Gateway."
}

variable "description" {
  type        = string
  description = "Description of the Transit Gateway."
  default     = "Enterprise Multi-Region Transit Gateway"
}

variable "vpc_attachments" {
  type = map(object({
    vpc_id              = string
    subnet_ids          = list(string)
    dns_support         = optional(string, "enable")
    ipv6_support        = optional(string, "disable")
    transit_gateway_default_route_table_association = optional(bool, true)
    transit_gateway_default_route_table_propagation = optional(bool, true)
  }))
  description = "Map of VPC configurations to attach to the Transit Gateway."
  default     = {}
}

variable "tags" {
  type        = map(string)
  description = "Resource tags."
  default     = {}
}
