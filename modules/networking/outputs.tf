output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.my_vpc.id
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = {
    for key, subnet in aws_subnet.web_subnet :
    key => subnet.id
  }
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = {
    for key, subnet in aws_subnet.db_subnet :
    key => subnet.id
  }
}

output "internet_gateway_id" {
  description = "Internet Gateway ID"
  value       = aws_internet_gateway.igw.id
}