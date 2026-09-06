
output "tgw_id" {
  description = "The ID of the Transit Gateway"
  value       = aws_ec2_transit_gateway.main.id
}

output "tgw_arn" {
  description = "The ARN of the Transit Gateway"
  value       = aws_ec2_transit_gateway.main.arn
}

output "vpc_attachment_id" {
  description = "The ID of the TGW VPC Attachment"
  value       = aws_ec2_transit_gateway_vpc_attachment.main.id
}

output "workload_route_table_id" {
  description = "The ID of the Workload TGW Route Table"
  value       = aws_ec2_transit_gateway_route_table.workload_rt.id
}

output "peering_route_table_id" {
  description = "The ID of the Peering TGW Route Table"
  value       = aws_ec2_transit_gateway_route_table.peering_rt.id
}
