
output "vpc_id" {
  value = aws_vpc.main.id
}

output "private_subnet_ids" {
  value = aws_subnet.private[*].id
}

output "tgw_subnet_ids" {
  value = aws_subnet.tgw[*].id
}

output "private_route_table_id" {
  value = aws_route_table.private.id
}
