resource "aws_cloudwatch_event_rule" "failover" {
  name = "aurora-failover-rule"
  event_pattern = jsonencode({
    source      = ["aws.rds"],
    "detail-type" = ["RDS DB Cluster Event"],
    detail      = { EventCategories = ["failover"] }
  })
}
