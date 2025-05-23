resource "aws_lambda_function" "failover_ui" {
  filename      = "lambda.zip"
  function_name = "global-db-failover-ui"
  role          = aws_iam_role.lambda_failover.arn
  handler       = "index.handler"
  runtime       = "python3.9"
  timeout       = 30
}

resource "aws_api_gateway_rest_api" "failover_api" {
  name        = "GlobalDBFailoverAPI"
  description = "API for initiating global database failover"
}

resource "aws_api_gateway_deployment" "failover_deployment" {
  rest_api_id = aws_api_gateway_rest_api.failover_api.id
  stage_name  = "prod"
}

resource "aws_iam_role" "step_functions" {
  name = "step-functions-global-db-failover"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "states.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "step_functions_policy" {
  name = "step-functions-global-db-failover-policy"
  role = aws_iam_role.step_functions.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "rds:FailoverGlobalCluster",
          "rds:DescribeGlobalClusters",
          "rds:DescribeDBClusters"
        ],
        Resource = "*"
      }
    ]
  })
}
resource "aws_sfn_state_machine" "failover_workflow" {
  name     = "global-db-failover-workflow"
  role_arn = aws_iam_role.step_functions.arn

  definition = <<EOF
{
  "Comment": "Global Database Failover Workflow",
  "StartAt": "VerifySecondary",
  "States": {
    "VerifySecondary": {
      "Type": "Task",
      "Resource": "arn:aws:states:::aws-sdk:rds:describeDBClusters",
      "Parameters": {
       "DbClusterIdentifier": "aurora-cluster-secondary"
      },
      "Next": "InitiateFailover"
    },
    "InitiateFailover": {
      "Type": "Task",
      "Resource": "arn:aws:states:::aws-sdk:rds:failoverGlobalCluster",
      "Parameters": {
        "GlobalClusterIdentifier": "my-global-cluster-1",
        "TargetDbClusterIdentifier": "arn:aws:rds:us-west-2:679720146112:cluster:aurora-cluster-secondary"
      },
      "End": true
    }
  }
}
EOF
}
resource "aws_ssm_document" "failover_command" {
  name          = "global-db-failover"
  document_type = "Command"

  content = <<DOC
{
  "schemaVersion": "2.2",
  "description": "Execute Global Database Failover",
  "mainSteps": [
    {
      "action": "aws:runShellScript",
      "name": "failover",
      "inputs": {
        "runCommand": [
          "aws rds failover-global-cluster --global-cluster-identifier my-global-cluster-1 --target-db-cluster-identifier arn:aws:rds:us-west-2:679720146112:cluster:aurora-cluster-secondary"
        ]
      }
    }
  ]
}
DOC
}

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
# resource "aws_iam_role" "lambda_failover" {
#   assume_role_policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [{
#       Action = "sts:AssumeRole",
#       Effect = "Allow",
#       Principal = { Service = "lambda.amazonaws.com" }
#     }]
#   })
# }
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
