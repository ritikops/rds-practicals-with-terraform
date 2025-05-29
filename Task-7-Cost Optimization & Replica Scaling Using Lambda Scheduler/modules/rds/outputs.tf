output "rds_cluster_endpoint" {
  value = aws_rds_cluster.aurora.endpoint
}

output "rds_reader_endpoint" {
  value = aws_rds_cluster.aurora.reader_endpoint
}

output "db_cluster_id" {
  value = aws_rds_cluster.aurora.id
}

output "endpoint" {
  value = aws_rds_cluster.aurora.endpoint
}
