# resource "aws_route53_zone" "main" {
#   name = "blogwick.publicvm.com"
# }
# resource "aws_route53_health_check" "primary" {
#   fqdn              = var.primary_endpoint
#   port              = 3306
#   type              = "TCP"
#   request_interval  = 30
#   failure_threshold = 3
# }

# resource "aws_route53_record" "primary" {
#   zone_id = var.hosted_zone_id
#   name    = "db-primary.example.com"
#   type    = "CNAME"
#   ttl     = 60
#   records = [aws_rds_cluster.primary.endpoint]
# }

# resource "aws_route53_record" "secondary" {
#   zone_id = var.hosted_zone_id
#   name    = "db-secondary.example.com"
#   type    = "CNAME"
#   ttl     = 60
#   records = [aws_rds_cluster.secondary.endpoint]
# }
