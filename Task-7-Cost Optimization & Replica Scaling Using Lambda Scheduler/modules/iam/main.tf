resource "aws_iam_role" "lambda_exec_role" {
  name               = "lambda-rds-scaling-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
  description = "IAM role for Lambda to manage RDS scaling"
  path        = "/"
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_policy" "rds_scaling_policy" {
  name        = "rds-scaling-policy"
  description = "Policy to allow RDS scaling operations from Lambda"
  policy      = file("${path.module}/policies/rds-scaling-policy.json")
}

resource "aws_iam_role_policy_attachment" "rds_scaling_attach" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = aws_iam_policy.rds_scaling_policy.arn
}
resource "aws_iam_policy" "ta_lambda_policy" {
  name = "TrustedAdvisorLambdaPolicy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement: [
      {
        Effect: "Allow",
        Action: [
          "support:DescribeTrustedAdvisorChecks",
          "support:DescribeTrustedAdvisorCheckResult"
        ],
        Resource: "*"
      },
      {
        Effect: "Allow",
        Action: [
          "sns:Publish",
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource: "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_ta_policy" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = aws_iam_policy.ta_lambda_policy.arn
}
