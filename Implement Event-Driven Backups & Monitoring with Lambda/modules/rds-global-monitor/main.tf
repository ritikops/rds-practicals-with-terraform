locals {
  lambda_zip_path = "${path.module}/lambda/lambda_function.zip"
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda/main.py"
  output_path = local.lambda_zip_path
}

# Lambda Function
resource "aws_lambda_function" "rds_monitor" {
  filename         = local.lambda_zip_path
  function_name    = var.function_name
  role             = aws_iam_role.lambda_exec.arn
  handler          = "main.lambda_handler"
  runtime          = "python3.9"
  timeout          = var.lambda_timeout
  memory_size      = var.lambda_memory_size
  layers           = var.lambda_layers
  
  environment {
    variables = merge({
      S3_BACKUP_BUCKET = var.backup_bucket_name
      EXPORT_IAM_ROLE  = var.create_export_role ? aws_iam_role.rds_export[0].arn : ""
      KMS_KEY_ID       = var.kms_key_arn != "" ? var.kms_key_arn : aws_kms_key.rds_export[0].arn
    }, var.lambda_environment_variables)
  }

  depends_on = [
    data.archive_file.lambda_zip,
    aws_cloudwatch_log_group.lambda_logs
  ]
}

# IAM Role for Lambda
resource "aws_iam_role" "lambda_exec" {
  name = "${var.function_name}-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

# IAM Policy for Lambda
resource "aws_iam_role_policy" "lambda_policy" {
  name = "${var.function_name}-lambda-policy"
  role = aws_iam_role.lambda_exec.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = concat([
      {
        Effect = "Allow"
        Action = [
          "rds:Describe*",
          "rds:List*",
          "rds:StartExportTask"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "sns:Publish"
        ]
        Resource = var.sns_topic_arn != "" ? var.sns_topic_arn : aws_sns_topic.rds_alerts[0].arn
      },
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetBucketLocation"
        ]
        Resource = [
          "arn:aws:s3:::${var.backup_bucket_name}",
          "arn:aws:s3:::${var.backup_bucket_name}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "cloudwatch:PutMetricData"
        ]
        Resource = "*"
      }],
      var.additional_lambda_policy_statements
    )
  })
}

# IAM Role for RDS Export
resource "aws_iam_role" "rds_export" {
  count = var.create_export_role ? 1 : 0
  name  = "${var.function_name}-snapshot-export-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "export.rds.amazonaws.com"
      }
    }]
  })
}

# IAM Policy for RDS Export
resource "aws_iam_role_policy" "rds_export_policy" {
  count = var.create_export_role ? 1 : 0
  name  = "${var.function_name}-snapshot-export-policy"
  role  = aws_iam_role.rds_export[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject*",
          "s3:ListBucket",
          "s3:GetBucketLocation"
        ]
        Resource = [
          "arn:aws:s3:::${var.backup_bucket_name}",
          "arn:aws:s3:::${var.backup_bucket_name}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ]
        Resource = var.kms_key_arn != "" ? var.kms_key_arn : aws_kms_key.rds_export[0].arn
      }
    ]
  })
}

# KMS Key for Encryption
resource "aws_kms_key" "rds_export" {
  count               = var.kms_key_arn == "" ? 1 : 0
  description         = "KMS key for RDS snapshot exports"
  deletion_window_in_days = var.kms_key_deletion_window
  enable_key_rotation = var.kms_key_rotation
  policy              = var.kms_key_policy != "" ? var.kms_key_policy : null
}

# SNS Topic for Alerts
resource "aws_sns_topic" "rds_alerts" {
  count = var.sns_topic_arn == "" ? 1 : 0
  name  = "${var.function_name}-alerts"
}

# EventBridge Rule
resource "aws_cloudwatch_event_rule" "rds_events" {
  name        = "${var.function_name}-events"
  description = "Capture important RDS Global Cluster events"

  event_pattern = jsonencode({
    source      = ["aws.rds"]
    detail-type = ["RDS DB Instance Event", "RDS DB Cluster Event"]
    detail = {
      EventCategories = var.monitored_event_categories
      SourceType      = ["DB_INSTANCE", "DB_CLUSTER"]
    }
  })
}

# EventBridge Target
resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.rds_events.name
  target_id = "SendToLambda"
  arn       = aws_lambda_function.rds_monitor.arn
}

# Lambda Permission
resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.rds_monitor.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.rds_events.arn
}

# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "lambda_logs" {
  name              = "/aws/lambda/${var.function_name}"
  retention_in_days = var.log_retention_days
}