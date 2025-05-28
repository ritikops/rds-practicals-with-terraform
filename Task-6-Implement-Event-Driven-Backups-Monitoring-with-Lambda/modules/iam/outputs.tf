output "lambda_role_arn" {
  value = aws_iam_role.lambda_exec.arn
}

output "export_role_arn" {
  value = aws_iam_role.rds_export_role.arn
}
