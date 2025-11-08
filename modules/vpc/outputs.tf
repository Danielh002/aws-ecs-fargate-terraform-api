output "vpc_id" {
  value       = aws_vpc.this.id
  description = "ID of the created VPC."
}

output "public_subnet_ids" {
  value       = [for subnet in aws_subnet.public : subnet.id]
  description = "IDs of the public subnets."
}

output "private_subnet_ids" {
  value       = [for subnet in aws_subnet.private : subnet.id]
  description = "IDs of the private subnets."
}
