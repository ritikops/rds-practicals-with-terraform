output "cluster_id" {
  value = aws_rds_cluster.primary.id
}

output "cluster_arn" {
  value = aws_rds_cluster.primary.arn
}
output "kms_key_arn" {
  value = aws_kms_key.rds.arn
}

output "security_group_id" {
  value = aws_security_group.rds.id
}
output "primary_cluster_id" {
  value = var.primary_cluster_id
}

output "primary_cluster_arn" {
  value = var.primary_cluster_arn
}

output "secondary_cluster_id" {
  value = var.secondary_cluster_id
}

output "secondary_cluster_arn" {
  value = var.secondary_cluster_arn
}