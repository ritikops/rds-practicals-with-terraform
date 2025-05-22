resource "aws_cloudwatch_metric_alarm" "primary_unhealthy" {
  alarm_name          = "aurora-primary-unhealthy"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "UnhealthyHostCount"
  namespace           = "AWS/Route53"
  period              = 60
  statistic           = "Average"
  threshold           = 1
  dimensions = {
    HealthCheckId = var.primary_health_check_id
  }
  alarm_actions = [var.lambda_function_arn]
}
resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch-${var.primary_health_check_id}"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_function_name
  principal     = "cloudwatch.amazonaws.com"
  source_arn    = aws_cloudwatch_metric_alarm.primary_unhealthy.arn
}

resource "aws_cloudwatch_event_rule" "failover" {
  name = "aurora-failover-rule"
  event_pattern = jsonencode({
    source      = ["aws.rds"],
    "detail-type" = ["RDS DB Cluster Event"],
    detail      = { EventCategories = ["failover"] }
  })
}
resource "aws_cloudwatch_event_rule" "failover_trigger" {
  name        = "failover-scheduled-rule"
  description = "Trigger failover Lambda on schedule"
  schedule_expression = "rate(5 minutes)"
}

resource "aws_cloudwatch_event_target" "to_lambda" {
  rule      = aws_cloudwatch_event_rule.failover_trigger.name
  target_id = "failover-lambda"
  arn       = var.lambda_function_arn
}

resource "aws_lambda_permission" "cw_invoke" {
  statement_id  = "AllowExecutionFromCloudWatch-Schedule"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.failover_trigger.arn
}
