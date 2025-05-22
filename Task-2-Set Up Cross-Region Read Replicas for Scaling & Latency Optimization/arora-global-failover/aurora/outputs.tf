output "primary_endpoint" {
  value = aws_rds_cluster.primary.endpoint
}

output "secondary_endpoint" {
  value = aws_rds_cluster.secondary.endpoint
}
output "secondary_cluster_id" {
  value = aws_rds_cluster.secondary.id
}