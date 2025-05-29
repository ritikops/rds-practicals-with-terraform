resource "aws_lambda_function" "rds_scheduler" {
  filename         = "${path.module}/scedular.zip"
  function_name    = "rds-replica-scheduler"
  role             = var.lambda_role_arn
  handler          = "scedular.lambda_handler"
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

resource "aws_sns_topic" "idle_rds_alerts" {
  name = "idle-rds-alerts"
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
resource "aws_cloudwatch_event_rule" "daily_check" {
  name                = "daily-trusted-advisor-check"
  schedule_expression = "rate(1 day)"
}

resource "aws_lambda_function" "trusted_advisor_check" {
  function_name = "trusted-advisor-idle-rds-check"
  role          = var.lambda_exec_role_arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.11"

  filename         = "${path.module}/scedular.zip"
  source_code_hash = filebase64sha256("${path.module}/scedular.zip")

  environment {
    variables = {
      SNS_TOPIC = var.sns_topic_arn
    }
  }

  timeout = 60
}

resource "aws_cloudwatch_event_target" "invoke_lambda" {
  rule      = aws_cloudwatch_event_rule.daily_check.name
  target_id = "checkIdleRDS"
  arn       = aws_lambda_function.trusted_advisor_check.arn
}

resource "aws_lambda_permission" "allow_cw" {
  statement_id  = "AllowExecutionFromCW"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.trusted_advisor_check.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.daily_check.arn
}
