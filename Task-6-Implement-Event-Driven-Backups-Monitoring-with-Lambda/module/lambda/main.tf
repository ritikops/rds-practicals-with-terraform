resource "aws_iam_role" "lambda_exec" {
  name = "lambda-monitoring-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "lambda_logs" {
  name       = "lambda-cloudwatch"
  roles      = [aws_iam_role.lambda_exec.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "rds_monitor" {
  filename         = "${path.module}/lambda_function_payload.zip"
  function_name    = "rds-monitor-lambda"
  role             = aws_iam_role.lambda_exec.arn
  handler          = "index.handler"
  runtime          = "python3.11"
  source_code_hash = filebase64sha256("${path.module}/lambda_function_payload.zip")

  environment {
    variables = {
      BUCKET_NAME       = var.snapshot_s3_bucket
      SNS_TOPIC_ARN     = var.sns_topic_arn
      GLOBAL_CLUSTER_ID = var.rds_global_cluster_id
    }
  }
}

resource "aws_cloudwatch_event_rule" "rds_events" {
  name        = "rds-events-rule"
  description = "Trigger Lambda on RDS snapshot/failover/lag events"
  event_pattern = jsonencode({
    source      = ["aws.rds"],
    detail-type = ["RDS DB Snapshot Event", "RDS DB Instance Event"]
  })
}

resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.rds_events.name
  target_id = "lambda-rds-monitor"
  arn       = aws_lambda_function.rds_monitor.arn
}

resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.rds_monitor.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.rds_events.arn
}
