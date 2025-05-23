module "primary_monitoring" {
  source = "../primary"

  providers = {
    aws = aws.primary_region
  }
}

module "secondary_monitoring" {
  source = "../secondary"

  providers = {
    aws = aws.secondary_region
  }
}

resource "aws_iam_role" "rds_monitor" {
  name = "rds-global-monitor-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy" "rds_monitor_policy" {
  name = "rds-global-monitor-policy"
  role = aws_iam_role.rds_monitor.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "rds:Describe*",
          "rds:List*",
          "rds:CreateDBClusterSnapshot",
          "rds:StartExportTask"
        ],
        Resource = [
          module.primary_monitoring.cluster_arn,
          module.secondary_monitoring.cluster_arn
        ]
      },
      {
        Effect   = "Allow",
        Action   = ["s3:PutObject"],
        Resource = ["arn:aws:s3:::${var.backup_bucket}/*"]
      },
      {
        Effect   = "Allow",
        Action   = ["sns:Publish"],
        Resource = [var.sns_topic_arn]
      }
    ]
  })
}

resource "aws_lambda_function" "rds_monitor" {
  filename      = "${path.module}/lambda/rds_monitor.zip"
  function_name = "rds-global-monitor"
  role          = aws_iam_role.rds_monitor.arn
  handler       = "rds_monitor.lambda_handler"
  runtime       = "python3.9"
  timeout       = 120

  environment {
    variables = {
      PRIMARY_CLUSTER   = module.primary_monitoring.cluster_id
      SECONDARY_CLUSTER = module.secondary_monitoring.cluster_id
      BACKUP_BUCKET     = var.backup_bucket
      SNS_TOPIC_ARN     = var.sns_topic_arn
    }
  }
}

resource "aws_cloudwatch_event_rule" "rds_events" {
  name        = "rds-global-monitor-events"
  description = "Capture RDS Global Cluster events"

  event_pattern = jsonencode({
    source      = ["aws.rds"],
    detail-type = ["RDS DB Cluster Event"],
    detail = {
      SourceArn = [
        module.primary_monitoring.cluster_arn,
        module.secondary_monitoring.cluster_arn
      ]
    }
  })
}

resource "aws_cloudwatch_event_target" "lambda" {
  rule      = aws_cloudwatch_event_rule.rds_events.name
  target_id = "SendToLambda"
  arn       = aws_lambda_function.rds_monitor.arn
}

resource "aws_lambda_permission" "eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.rds_monitor.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.rds_events.arn
}