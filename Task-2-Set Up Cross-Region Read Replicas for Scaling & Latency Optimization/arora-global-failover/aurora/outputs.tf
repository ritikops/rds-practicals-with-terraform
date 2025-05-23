output "primary_endpoint" {
  value = aws_rds_cluster.primary.endpoint
}

output "secondary_endpoint" {
  value = aws_rds_cluster.secondary.endpoint
}
output "secondary_cluster_id" {
  value = aws_rds_cluster.secondary.id
}
output "primary_cluster_identifier" {
  value = aws_rds_cluster.primary.id
}

output "replica_cluster_identifier" {
  value = aws_rds_cluster.secondary.id
}

output "global_cluster_identifier" {
  value = aws_rds_global_cluster.global.id
}