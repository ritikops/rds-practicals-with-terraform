resource "aws_lambda_function" "failover" {
  function_name = var.function_name
  role          = aws_iam_role.lambda_failover.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.9"
  filename      = "${path.module}/lambda/lambda.zip"
  source_code_hash = filebase64sha256("${path.module}/lambda/lambda.zip")
  # ... other config ...


  environment {
    variables = {
      DB_HOSTNAME       = var.db_hostname
      PRIMARY_REGION    = var.primary_region
      SECONDARY_REGION  = var.secondary_region
      GLOBAL_CLUSTER_ID = var.global_cluster_id
      HOSTED_ZONE_ID    = var.hosted_zone_id
    }
  }
}

resource "aws_iam_role" "lambda_exec" {
  name = "lambda_failover_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Principal = {
        Service = "lambda.amazonaws.com"
      },
      Effect = "Allow",
      Sid    = ""
    }]
  })
}
