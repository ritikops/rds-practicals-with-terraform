
resource "aws_route53_record" "primary" {
  # weighted_routing_policy {
  #   weight = 0
  # }
  zone_id = aws_route53_zone.main.zone_id
  name    = var.db_hostname
  type    = "CNAME"
  ttl     = 60
  set_identifier = "primary"

  failover_routing_policy {
    type = "PRIMARY"
  }

  health_check_id = aws_route53_health_check.primary.id

  records = [var.primary_endpoint]
}

resource "aws_route53_record" "secondary" {
  # weighted_routing_policy {
  #   weight = 100
  # }
  zone_id = aws_route53_zone.main.zone_id
  # var.hosted_zone_id
  name    = var.db_hostname
  type    = "CNAME"
  ttl     = 60
  set_identifier = "secondary"

  failover_routing_policy {
    type = "SECONDARY"
  }

  records = [var.secondary_endpoint]
}