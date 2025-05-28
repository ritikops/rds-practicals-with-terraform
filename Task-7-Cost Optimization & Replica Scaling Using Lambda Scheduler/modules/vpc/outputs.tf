output "vpc_id" {
  value = aws_vpc.main.id
}

output "private_subnet_ids" {
  value = aws_subnet.private[*].id
}

output "subnet_group_name" {
  value = aws_db_subnet_group.rds_subnet_group.name
}
