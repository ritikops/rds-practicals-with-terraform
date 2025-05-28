output "lambda_arn" {
  description = "The ARN of the Lambda function"
  value       = aws_lambda_function.rds_scheduler.arn
}

output "lambda_name" {
  description = "The name of the Lambda function"
  value       = aws_lambda_function.rds_scheduler.function_name
}
