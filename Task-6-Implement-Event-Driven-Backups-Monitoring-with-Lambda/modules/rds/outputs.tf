output "global_cluster_id" {
  value = aws_rds_global_cluster.this.id
}

output "snapshot_s3_bucket" {
  value = aws_s3_bucket.snapshot_backup.bucket
}
