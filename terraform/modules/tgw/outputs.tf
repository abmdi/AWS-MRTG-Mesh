output "tgw_id" {
  value       = aws_ec2_transit_gateway.tgw.id
  description = "The ID of the Transit Gateway."
}

output "tgw_arn" {
  value       = aws_ec2_transit_gateway.tgw.arn
  description = "The ARN of the Transit Gateway."
}

output "attachment_ids" {
  value       = { for k, v in aws_ec2_transit_gateway_vpc_attachment.attachments : k => v.id }
  description = "Map of VPC attachment IDs."
}
