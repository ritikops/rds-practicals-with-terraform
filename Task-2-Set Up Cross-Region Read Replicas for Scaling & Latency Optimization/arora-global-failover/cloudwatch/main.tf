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
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.failover_trigger.arn
}
