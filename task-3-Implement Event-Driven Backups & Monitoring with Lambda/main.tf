resource "aws_s3_bucket" "rds_backups" {
  bucket        = "prod-rds-global-backups-${random_id.bucket_suffix.hex}"
  force_destroy = true

  tags = {
    Name = "prod-rds-global-backups"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "rds_backups" {
  bucket = aws_s3_bucket.rds_backups.id

  rule {
    id     = "backup-retention"
    status = "Enabled"

    filter {} # Applies the rule to all objects in the bucket

    expiration {
      days = 90
    }

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }
  }
}

# Random suffix for bucket name
resource "random_id" "bucket_suffix" {
  byte_length = 4
}

# Then reference it in your module


module "rds_monitoring" {
  source = "./modules/rds-global-monitor"

  function_name        = "prod-rds-global-monitor"
  backup_bucket_name = aws_s3_bucket.rds_backups.bucket

#   sns_topic_arn       = aws_sns_topic.existing_alerts.arn # Optional - use existing topic
#   kms_key_arn         = aws_kms_key.existing_key.arn      # Optional - use existing key

  lambda_environment_variables = {
    SLACK_WEBHOOK_URL = "https://iqinfinite.webhook.office.com/webhookb2/f20e6eb8-982c-4024-9e60-a2e46a27cb80@b6859703-4fa9-46af-b7a6-c453ed19dd3d/IncomingWebhook/a626e9f106e6424a8b5c186590c89069/97973af2-3701-4b6c-b775-bb789e97f515/V2Zo8f25eJdbhoQ4_BAHlDFfsebmrSihsr3PIhPx9H5bY1"
  }

  additional_lambda_policy_statements = [
    {
      Effect = "Allow"
      Action = [
        "secretsmanager:GetSecretValue"
      ]
      Resource = [
        "arn:aws:secretsmanager:us-east-1:123456789012:secret:rds-credentials-*"
      ]
    }
  ]
}

# Example of creating SNS subscriptions
resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = module.rds_monitoring.sns_topic_arn
  protocol  = "email"
  endpoint  = "alerts@example.com"
}
# provider "aws" {
#   region = "us-east-1" # Change to your preferred region
# }

# # Create the RDS monitoring module
# module "rds_monitoring" {
#   source = "./modules/rds-global-monitor"

#   # Required parameters
#   function_name      = "prod-rds-global-monitor"
#   backup_bucket_name = "prod-rds-global-backups-${random_id.bucket_suffix.hex}"

#   # Optional parameters - remove these if you want to use the module's default SNS topic and KMS key
#   # sns_topic_arn = aws_sns_topic.custom_alerts.arn  # Uncomment if you create a custom topic
#   # kms_key_arn   = aws_kms_key.custom_key.arn       # Uncomment if you create a custom key

#   # Example of adding a Slack webhook URL
#   lambda_environment_variables = {
#     SLACK_WEBHOOK_URL = var.slack_webhook_url
#   }
# }

# # Random suffix for bucket name to ensure uniqueness
# resource "random_id" "bucket_suffix" {
#   byte_length = 4
# }

# # Example of how to create a custom SNS topic (uncomment if needed)
# # resource "aws_sns_topic" "custom_alerts" {
# #   name = "custom-rds-alerts"
# # }

# # Example of how to create a custom KMS key (uncomment if needed)
# # resource "aws_kms_key" "custom_key" {
# #   description             = "Custom KMS key for RDS exports"
# #   deletion_window_in_days = 10
# #   enable_key_rotation     = true
# # }

# # Example SNS email subscription (using the module's created topic)
# resource "aws_sns_topic_subscription" "email_subscription" {
#   topic_arn = module.rds_monitoring.sns_topic_arn
#   protocol  = "email"
#   endpoint  = var.alert_email
# }

# # Variables
# variable "alert_email" {
#   description = "Email address for receiving alerts"
#   type        = string
# }

# variable "slack_webhook_url" {
#   description = "Slack webhook URL for notifications (optional)"
#   type        = string
#   default     = ""
# }