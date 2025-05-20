data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/lambda"
  output_path = "${path.module}/lambda/lambda.zip"
}

resource "aws_lambda_function" "failover" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = "rds_failover_handler"
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.9"
  role             = aws_iam_role.lambda_failover.arn
  source_code_hash = filebase64sha256(data.archive_file.lambda_zip.output_path)
  environment {
    variables = {
      PRIMARY_REGION    = var.primary_region
      SECONDARY_REGION  = var.secondary_region
      GLOBAL_CLUSTER_ID = var.global_cluster_id
      HOSTED_ZONE_ID    = var.hosted_zone_id
      DB_HOSTNAME       = var.db_hostname
    }
  }
}
