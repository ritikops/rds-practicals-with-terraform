output "primary_subnet_ids" {
  value = [
    aws_subnet.primary_a.id,
    aws_subnet.primary_b.id
  ]
}

output "secondary_subnet_ids" {
  value = [
    aws_subnet.secondary_a.id,
    aws_subnet.secondary_b.id
  ]
}
output "secondary_vpc_id" {
  value = aws_vpc.secondary.id
}