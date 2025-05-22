output "lambda_function_arn" {
  description = "ARN of the monitoring Lambda function"
  value       = aws_lambda_function.rds_monitor.arn
}

output "lambda_function_name" {
  description = "Name of the monitoring Lambda function"
  value       = aws_lambda_function.rds_monitor.function_name
}

output "sns_topic_arn" {
  description = "ARN of the SNS topic for alerts"
  value       = var.sns_topic_arn != "" ? var.sns_topic_arn : aws_sns_topic.rds_alerts[0].arn
}

output "kms_key_arn" {
  description = "ARN of the KMS key used for encryption"
  value       = var.kms_key_arn != "" ? var.kms_key_arn : aws_kms_key.rds_export[0].arn
}

output "event_rule_arn" {
  description = "ARN of the EventBridge rule"
  value       = aws_cloudwatch_event_rule.rds_events.arn
}

output "export_role_arn" {
  description = "ARN of the RDS export role"
  value       = var.create_export_role ? aws_iam_role.rds_export[0].arn : null
}