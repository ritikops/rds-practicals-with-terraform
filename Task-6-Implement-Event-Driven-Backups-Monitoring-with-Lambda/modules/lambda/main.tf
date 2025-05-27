resource "aws_kms_key" "snapshot_export" {
  description = "KMS key for RDS snapshot export"
}
resource "aws_iam_policy" "rds_export_policy" {
  name = "lambda-rds-export-permissions"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "rds:StartExportTask",
          "rds:DescribeDBSnapshots"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Principal = {
          Service = "rds.amazonaws.com"
        },

        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "sts:ListBucket"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:GenerateDataKey",
          "kms:ReEncryptFrom",
          "kms:ReEncryptTo"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "rds:StartExportTask",
          "rds:DescribeExportTasks"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_export_attach" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = aws_iam_policy.rds_export_policy.arn
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
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.11"
  source_code_hash = filebase64sha256("${path.module}/lambda_function_payload.zip")

  environment {
    variables = {
      BUCKET_NAME       = var.snapshot_s3_bucket
      SNS_TOPIC_ARN     = var.sns_topic_arn
      GLOBAL_CLUSTER_ID = var.rds_global_cluster_id
      KMS_KEY_ID        = var.kms_key_id
      EXPORT_ROLE_ARN   = var.export_role_arn
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
resource "aws_cloudwatch_event_rule" "rds_failover_events" {
  name        = "rds-failover-events"
  description = "Catch RDS failover-related events"
  event_pattern = jsonencode({
    "source" : ["aws.rds"],
    "detail-type" : ["RDS DB Instance Event"],
    "detail" : {
      "EventID" : ["RDS-EVENT-0049", "RDS-EVENT-0050"]
    }
  })
}

resource "aws_cloudwatch_event_target" "failover_event_target" {
  rule      = aws_cloudwatch_event_rule.rds_failover_events.name
  target_id = "lambda-failover-alert"
  arn       = aws_lambda_function.rds_monitor.arn
}
resource "aws_cloudwatch_metric_alarm" "replica_lag_alarm" {
  alarm_name          = "rds-replica-lag"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "ReplicaLag"
  namespace           = "AWS/RDS"
  period              = "60"
  statistic           = "Average"
  threshold           = 100
  alarm_description   = "Alarm when RDS replica lag exceeds 100 seconds"
  dimensions = {
    DBInstanceIdentifier = var.rds_instance_identifier
  }
  alarm_actions = [aws_sns_topic.lambda_alert.arn]
}