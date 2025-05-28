resource "aws_cloudwatch_event_rule" "scale_schedule_up" {
  name                = "scale-up-read-replicas"
  schedule_expression = "cron(0 9 * * ? *)"
}

resource "aws_cloudwatch_event_rule" "scale_schedule_down" {
  name                = "scale-down-read-replicas"
  schedule_expression = "cron(0 18 * * ? *)"
}

resource "aws_cloudwatch_event_target" "scale_up" {
  rule = aws_cloudwatch_event_rule.scale_schedule_up.name
  target_id = "scaleUpLambda"
  arn = var.lambda_arn
  input = jsonencode({ "desired_count": 2 })
}

resource "aws_cloudwatch_event_target" "scale_down" {
  rule = aws_cloudwatch_event_rule.scale_schedule_down.name
  target_id = "scaleDownLambda"
  arn = var.lambda_arn
  input = jsonencode({ "desired_count": 0 })
}
resource "aws_lambda_permission" "allow_cloudwatch_up" {
  statement_id  = "AllowExecutionFromCloudWatchUp"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.scale_schedule_up.arn
}

resource "aws_lambda_permission" "allow_cloudwatch_down" {
  statement_id  = "AllowExecutionFromCloudWatchDown"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.scale_schedule_down.arn
}
