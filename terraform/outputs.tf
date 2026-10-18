output "primary_tgw_id" {
  value       = module.tgw_primary.tgw_id
  description = "ID of the Primary Transit Gateway."
}

output "secondary_tgw_id" {
  value       = module.tgw_secondary.tgw_id
  description = "ID of the Secondary Transit Gateway."
}

output "primary_vpc_id" {
  value       = module.vpc_primary.vpc_id
  description = "ID of the Primary VPC."
}

output "secondary_vpc_id" {
  value       = module.vpc_secondary.vpc_id
  description = "ID of the Secondary VPC."
}
