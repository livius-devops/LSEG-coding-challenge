output "subnet_ids_public" {
  value       = [for subnet in aws_subnet.public : subnet.id]
}

output "subnet_ids_private" {
  value       = [for subnet in aws_subnet.private : subnet.id]
}

output "subnet_ids_db" {
  value       = [for subnet in aws_subnet.db : subnet.id]
}

output "vpc_id" {
  value       = aws_vpc.this.id
}

