resource "aws_lambda_function" "failover" {
  function_name = var.function_name
  role          = aws_iam_role.lambda_failover.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.12"
  filename      = "${path.module}/lambda/lambda.zip"
  source_code_hash = filebase64sha256("${path.module}/lambda/lambda.zip")
  timeout = 120
  # ... other config ...


  environment {
    variables = {
      DB_HOSTNAME       = var.db_hostname
      PRIMARY_REGION    = var.primary_region
      SECONDARY_REGION  = var.secondary_region
      SECONDARY_CLUSTER_ID = var.secondary_cluster_id
      GLOBAL_CLUSTER_ID = var.global_cluster_id
      HOSTED_ZONE_ID    = var.hosted_zone_id
    }
  }
}

# resource "aws_iam_role_policy" "lambda_policy" {
#   name = "${var.function_name}-lambda-policy"
#   role = aws_iam_role.lambda_exec.id

#   policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Effect = "Allow",
#         Action = [
#           "rds:FailoverGlobalCluster",
#           "rds:DescribeGlobalClusters",
#           "rds:DescribeDBClusters"
#         ],
#         Resource = "*"
#       }
#     ]
#   })
# }
