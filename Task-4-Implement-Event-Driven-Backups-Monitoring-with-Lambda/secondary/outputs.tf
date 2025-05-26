output "cluster_id" {
  value = aws_rds_cluster.secondary.id
}

output "cluster_arn" {
  value = aws_rds_cluster.secondary.arn
}
output "kms_key_arn" {
  value = aws_kms_key.secondary.arn
}

output "security_group_id" {
  value = aws_security_group.secondary.id
}


output "secondary_cluster_id" {
  value = var.secondary_cluster_id
}


output "secondary_cluster_arn" {
  value = var.secondary_cluster_arn
}