# resource "aws_route53_health_check" "primary" {
#   provider          = aws.primary
#   ip_address        = aws_rds_cluster.primary.endpoint
#   port              = 3306
#   type              = "TCP"
#   failure_threshold = "3"
#   request_interval  = "30"

#   tags = {
#     Name = "${var.cluster_identifier}-primary-health-check"
#   }
# }

# resource "aws_route53_record" "primary" {
#   provider = aws.primary
#   zone_id  = data.aws_route53_zone.this.zone_id
#   name     = "primary.${var.domain_name}"
#   type     = "CNAME"
#   ttl      = 60
#   records  = [aws_rds_cluster.primary.endpoint]
# }

# resource "aws_route53_record" "failover" {
#   provider = aws.primary
#   zone_id  = data.aws_route53_zone.this.zone_id
#   name     = var.domain_name
#   type     = "CNAME"
#   ttl      = 60

#   weighted_routing_policy {
#     weight = 90
#   }

#   set_identifier = "primary"
#   records        = [aws_rds_cluster.primary.endpoint]

#   health_check_id = aws_route53_health_check.primary.id
# }

# resource "aws_route53_record" "replica_failover" {
#   provider = aws.primary
#   zone_id  = data.aws_route53_zone.this.zone_id
#   name     = var.domain_name
#   type     = "CNAME"
#   ttl      = 60

#   weighted_routing_policy {
#     weight = 10
#   }

#   set_identifier = "replica"
#   records        = [aws_rds_cluster.replica.reader_endpoint]
# }
data "aws_route53_zone" "this" {
  name         = var.domain_name
  private_zone = false
}

resource "aws_route53_health_check" "primary" {
  ip_address        = var.primary_endpoint
  port              = 3306
  type              = "TCP"
  failure_threshold = "3"
  request_interval  = "30"
  tags = {
    Name = "${replace(var.domain_name, ".", "-")}-db-health-check"
  }
}

resource "aws_route53_record" "failover" {
  zone_id = data.aws_route53_zone.this.zone_id
  name    = "db.${var.domain_name}"
  type    = "CNAME"
  ttl     = 60

  weighted_routing_policy {
    weight = 100
  }

  set_identifier = "primary"
  records        = [var.primary_endpoint]

  health_check_id = aws_route53_health_check.primary.id
}

resource "aws_route53_record" "replica_failover" {
  zone_id = data.aws_route53_zone.this.zone_id
  name    = "db.${var.domain_name}"
  type    = "CNAME"
  ttl     = 60

  weighted_routing_policy {
    weight = 0
  }

  set_identifier = "replica"
  records        = [var.replica_endpoint]
}