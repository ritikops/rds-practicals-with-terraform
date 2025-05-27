resource "aws_lambda_function" "backup_monitor" {
  filename         = "${path.module}/lambda_function.zip"
  function_name    = var.function_name
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.11"
  role             = var.role_arn
  source_code_hash = filebase64sha256("${path.module}/lambda_function.zip")
  environment {
    variables = {
      S3_BUCKET = var.bucket_name
      SNS_TOPIC = var.sns_topic_arn
    }
  }

  tags = var.tags
}
