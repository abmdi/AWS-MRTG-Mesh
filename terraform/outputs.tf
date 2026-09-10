output "primary_vpc_id" {
  description = "Primary Region VPC ID"
  value       = module.vpc_primary.vpc_id
}

output "secondary_vpc_id" {
  description = "Secondary Region VPC ID"
  value       = module.vpc_secondary.vpc_id
}

output "primary_tgw_id" {
  description = "Primary Transit Gateway ID"
  value       = module.tgw_primary.tgw_id
}

output "secondary_tgw_id" {
  description = "Secondary Transit Gateway ID"
  value       = module.tgw_secondary.tgw_id
}

output "tgw_peering_attachment_id" {
  description = "Inter-Region TGW Peering Attachment ID"
  value       = aws_ec2_transit_gateway_peering_attachment.primary_to_secondary.id
}
