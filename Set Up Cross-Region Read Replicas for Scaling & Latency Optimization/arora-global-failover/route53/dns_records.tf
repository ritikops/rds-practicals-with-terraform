resource "aws_route53_record" "primary" {
  zone_id = var.hosted_zone_id
  name    = var.db_hostname
  type    = "CNAME"
  ttl     = 60
  set_identifier = "primary"

  failover_routing_policy {
    type = "PRIMARY"
  }

  health_check_id = aws_route53_health_check.primary.id

  records = [aws_rds_cluster.primary.endpoint]
}

resource "aws_route53_record" "secondary" {
  zone_id = var.hosted_zone_id
  name    = var.db_hostname
  type    = "CNAME"
  ttl     = 60
  set_identifier = "secondary"

  failover_routing_policy {
    type = "SECONDARY"
  }

  records = [aws_rds_cluster.secondary.endpoint]
}
