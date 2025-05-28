resource "aws_iam_role" "lambda_exec_role" {
  name = "lambda-rds-scaling-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Principal = { Service = "lambda.amazonaws.com" }
      Effect = "Allow"
    }]
  })
}

resource "aws_iam_policy_attachment" "lambda_basic_execution" {
  name       = "attach-lambda-basic-exec"
  roles      = [aws_iam_role.lambda_exec_role.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_policy" "rds_scaling_policy" {
  name   = "rds-scaling-policy"
  policy = file("${path.module}/policies/rds-scaling-policy.json")
}

resource "aws_iam_policy_attachment" "rds_scaling_attach" {
  name       = "attach-rds-scaling"
  roles      = [aws_iam_role.lambda_exec_role.name]
  policy_arn = aws_iam_policy.rds_scaling_policy.arn
}
