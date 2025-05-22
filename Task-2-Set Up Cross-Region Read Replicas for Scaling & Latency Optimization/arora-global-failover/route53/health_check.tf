# resource "aws_route53_health_check" "primary" {
#   fqdn = aws_rds_cluster.primary.endpoint
#   port = 3306
#   type = "TCP"
# }
resource "aws_route53_zone" "main" {
  name = "blogwick.publicvm.com"
}
resource "aws_route53_health_check" "primary" {
  fqdn              = var.primary_endpoint
  port              = 3306
  type              = "TCP"
  request_interval  = 30
  failure_threshold = 3
}