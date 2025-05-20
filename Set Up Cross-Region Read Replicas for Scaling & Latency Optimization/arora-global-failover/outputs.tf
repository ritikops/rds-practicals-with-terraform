output "primary_endpoint" {
  value = aws_rds_cluster.primary.endpoint
}

output "secondary_endpoint" {
  value = aws_rds_cluster.secondary.endpoint
}

output "dns_name" {
  value = format("%s.%s", var.db_hostname, var.hosted_zone_id)
}
