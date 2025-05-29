resource "aws_lambda_function" "rds_scheduler" {
  filename         = "${path.module}/scedular.zip"
  function_name    = "rds-replica-scheduler"
  role             = var.lambda_role_arn
  handler          = "scheduler.lambda_handler"
  runtime          = "python3.12"
  source_code_hash = filebase64sha256("${path.module}/scedular.zip")
  timeout          = 30
  memory_size      = 128

  environment {
    variables = {
      DB_CLUSTER_ID  = var.db_cluster_id
      INSTANCE_CLASS = var.instance_class
    }
  }
}

resource "aws_lambda_permission" "allow_cloudwatch_scale_up" {
  statement_id  = "AllowExecutionFromCloudWatchScaleUp"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.rds_scheduler.function_name
  principal     = "events.amazonaws.com"
  source_arn    = var.scale_up_event_rule_arn
}

resource "aws_lambda_permission" "allow_cloudwatch_scale_down" {
  statement_id  = "AllowExecutionFromCloudWatchScaleDown"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.rds_scheduler.function_name
  principal     = "events.amazonaws.com"
  source_arn    = var.scale_down_event_rule_arn
}
