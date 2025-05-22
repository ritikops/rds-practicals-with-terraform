output "failover_lambda_arn" {
  value = aws_lambda_function.failover.arn
}

output "failover_lambda_name" {
  value = aws_lambda_function.failover.function_name
}