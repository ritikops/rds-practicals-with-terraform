resource "aws_route53_health_check" "primary" {
  fqdn = aws_rds_cluster.primary.endpoint
  port = 3306
  type = "TCP"
}
