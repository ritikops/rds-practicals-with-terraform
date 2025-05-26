terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
  }
}


data "aws_caller_identity" "current" {}

# IAM Role for Lambda
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

resource "aws_s3_bucket" "rds_backups" {
  bucket        = "${var.backup_bucket}-${data.aws_caller_identity.current.account_id}"
  force_destroy = true
}

resource "aws_s3_bucket_lifecycle_configuration" "backups" {
  bucket = aws_s3_bucket.rds_backups.id

  rule {
    id     = "backup-retention"
    status = "Enabled"

    expiration {
      days = var.backup_retention_days
    }

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }
  }
}

# IAM Policy for Lambda

resource "aws_iam_policy" "rds_monitor_policy" {
  name        = "rds-global-monitor-policy"
  description = "Permissions for RDS monitoring Lambda function"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      # RDS Permissions
      {
        Effect = "Allow",
        Action = [
          "rds:Describe*",
          "rds:List*",
          "rds:CreateDBClusterSnapshot",
          "rds:StartExportTask",
          "rds:CopyDBClusterSnapshot"

        ],
        Resource = "*"
      },

      # S3 Backup Permissions
      {
        Effect = "Allow",
        Action = [
          "s3:PutObject",
          "s3:GetBucketLocation",
          "s3:ListBucket"
        ],
        Resource = [
          # "arn:aws:s3:::${var.backup_bucket}",
          # "arn:aws:s3:::${var.backup_bucket}/*"
          aws_s3_bucket.rds_backups.arn,
          "${aws_s3_bucket.rds_backups.arn}/*"
        ]
      },

      # SNS Notification Permissions
      {
        Effect   = "Allow",
        Action   = ["sns:Publish"],
        Resource = [aws_sns_topic.rds_alerts.arn]

      },

      # CloudWatch Logs
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = ["arn:aws:logs:*:*:*"]
      },

      # KMS Encryption
      {
        Effect = "Allow",
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:GenerateDataKey",
          "kms:DescribeKey"
        ],
        Resource = [
          var.primary_kms_key_arn,
          var.secondary_kms_key_arn
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.rds_monitor.name
  policy_arn = aws_iam_policy.rds_monitor_policy.arn
}

# Lambda Function
resource "aws_lambda_function" "rds_monitor" {
  filename      = "${path.module}/lambda/rds_monitor.zip"
  function_name = "rds-global-monitor"
  role          = aws_iam_role.rds_monitor.arn
  handler       = "rds_monitor.lambda_handler"
  runtime       = "python3.9"
  timeout       = 120
  memory_size   = 256

  environment {
    variables = {
      PRIMARY_CLUSTER_ID    = var.primary_cluster_id
      PRIMARY_CLUSTER_ARN   = var.primary_cluster_arn
      SECONDARY_CLUSTER_ID  = var.secondary_cluster_id
      SECONDARY_CLUSTER_ARN = var.secondary_cluster_arn
      S3_BACKUP_BUCKET      = aws_s3_bucket.rds_backups.id
      PRIMARY_KMS_KEY_ARN   = var.primary_kms_key_arn
      #BACKUP_BUCKET         = var.backup_bucket
      SNS_TOPIC_ARN         = aws_sns_topic.rds_alerts.arn
      SLACK_WEBHOOK_URL     = var.slack_webhook_url
      REPLICA_LAG_THRESHOLD = var.replica_lag_threshold
    }
  }
}

# EventBridge Rule for RDS Events
resource "aws_cloudwatch_event_rule" "rds_events" {
  name        = "rds-global-monitor-events"
  description = "Capture RDS Global Cluster events"

  event_pattern = jsonencode({
    source      = ["aws.rds"],
    detail-type = ["RDS DB Cluster Event", "RDS DB Instance Event"],
    detail = {
      EventCategories = [
        "backup",
        "failover",
        "notification",
        "maintenance"
      ],
      SourceArn = [
        var.primary_cluster_arn,
        var.secondary_cluster_arn
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
# SNS Topic for Alerts
resource "aws_sns_topic" "rds_alerts" {
  name = "rds-global-monitor-alerts"
}

# # S3 Bucket for Backups (if you don't already have one)
# resource "aws_s3_bucket" "rds_backups" {
#   bucket        = "${var.backup_bucket}-${data.aws_caller_identity.current.account_id}"
#   force_destroy = true
# }

# resource "aws_s3_bucket_lifecycle_configuration" "backups" {
#   bucket = aws_s3_bucket.rds_backups.id

#   rule {
#     id     = "backup-retention"
#     status = "Enabled"

#     expiration {
#       days = var.backup_retention_days
#     }

#     transition {
#       days          = 30
#       storage_class = "STANDARD_IA"
#     }
#   }
# }