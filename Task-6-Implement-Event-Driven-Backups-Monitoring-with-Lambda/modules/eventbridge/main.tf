resource "aws_cloudwatch_event_rule" "snapshot_complete" {
  name = "rds-snapshot-complete"
  event_pattern = jsonencode({
    source      = ["aws.rds"],
    detail-type = ["RDS DB Snapshot Event"]
  })

  tags = var.tags
}

resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.snapshot_complete.name
  target_id = "lambdaTarget"
  arn       = var.lambda_arn
}

resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_arn
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.snapshot_complete.arn
}
