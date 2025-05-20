resource "aws_cloudwatch_event_target" "to_lambda" {
  rule      = aws_cloudwatch_event_rule.failover.name
  target_id = "failover-lambda"
  arn       = aws_lambda_function.failover.arn
}

resource "aws_lambda_permission" "cw_invoke" {
  statement_id  = "AllowCWInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.failover.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.failover.arn
}
