resource "aws_lambda_function" "rds_scheduler" {
  filename         = "${path.module}/scheduler.zip"
  function_name    = "rds-replica-scheduler"
  role             = var.lambda_role_arn
  handler          = "scheduler.lambda_handler"
  runtime          = "python3.12"
  source_code_hash = filebase64sha256("${path.module}/scheduler.zip")
  timeout          = 30
  memory_size      = 128

  environment {
    variables = {
      DB_CLUSTER_ID  = var.db_cluster_id
      INSTANCE_CLASS = var.instance_class
    }
  }
}

resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.rds_scheduler.function_name
  principal     = "events.amazonaws.com"
  source_arn    = var.cloudwatch_event_arn
}
