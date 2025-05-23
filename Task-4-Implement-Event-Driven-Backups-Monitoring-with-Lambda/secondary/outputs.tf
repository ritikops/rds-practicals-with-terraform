output "cluster_id" {
  value = aws_rds_cluster.secondary.id
}

output "cluster_arn" {
  value = aws_rds_cluster.secondary.arn
}