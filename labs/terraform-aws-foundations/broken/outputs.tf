output "vpc_id" {
  description = "ID of the VPC."
  value       = aws_vpc.this.id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets, ordered by AZ."
  value       = aws_subnet.public[*].id
}

output "nat_gateway_id" {
  description = "ID of the NAT gateway, or null when enable_nat_gateway is false."
  value       = var.enable_nat_gateway ? aws_nat_gateway.this[0].id : null
}
