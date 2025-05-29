output "lambda_arn" {
  description = "The ARN of the Lambda function"
  value       = aws_lambda_function.rds_scheduler.arn
}

output "lambda_name" {
  description = "The name of the Lambda function"
  value       = aws_lambda_function.rds_scheduler.function_name
}
output "db_cluster_id" {
  description = "The ID of the RDS cluster"
  value       = var.db_cluster_id
}

output "endpoint" {
  description = "The endpoint of the RDS cluster"
  value       = var.endpoint
}
output "sns_topic_arn" {
  value = aws_sns_topic.idle_rds_alerts.arn
}