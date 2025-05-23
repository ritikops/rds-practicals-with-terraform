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

# resource "aws_iam_role_policy_attachment" "attach_failover" {
#   role       = aws_iam_role.lambda_failover.name
#   policy_arn = aws_iam_policy.lambda_policy.arn
# }

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
#   role = aws_iam_role.lambda_failover.id
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

# resource "aws_iam_role_policy_attachment" "attach_failover" {
#   role       = aws_iam_role.lambda_failover.name
#   policy_arn = aws_iam_role_policy.lambda_policy.id
# }
# resource "aws_iam_role_policy" "lambda_policy" {
#   name = "${var.function_name}-lambda-policy"
#   role = aws_iam_role.lambda_failover.id
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
# resource "aws_iam_role" "lambda_failover" {
#   name               = "${var.function_name}-failover-lambda-role"
#   description        = "IAM role for RDS Global Database failover Lambda function"
#   assume_role_policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [{
#       Action = "sts:AssumeRole",
#       Effect = "Allow",
#       Principal = {
#         Service = "lambda.amazonaws.com"
#       }
#     }]
#   })
# }


resource "aws_iam_role" "lambda_failover" {
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}


data "aws_caller_identity" "current" {}
resource "aws_iam_role_policy" "lambda_failover_policy" {
  name   = "${var.function_name}-failover-lambda-policy"
  role   = aws_iam_role.lambda_failover.id
  
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "rds:FailoverGlobalCluster",
          "rds:DescribeGlobalClusters",
          "rds:DescribeDBClusters",
          "rds:ListTagsForResource"
        ],
        Resource = [
          "arn:aws:rds::${data.aws_caller_identity.current.account_id}:global-cluster:${var.global_cluster_identifier}",
          "arn:aws:rds:${var.primary_region}:${data.aws_caller_identity.current.account_id}:cluster:${var.primary_cluster_identifier}",
          "arn:aws:rds:${var.replica_region}:${data.aws_caller_identity.current.account_id}:cluster:${var.replica_cluster_identifier}"
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}