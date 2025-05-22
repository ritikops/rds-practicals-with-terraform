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

resource "aws_iam_policy" "lambda_policy" {
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      { Effect = "Allow", Action = ["rds:PromoteReadReplicaDBCluster","rds:DescribeDBClusters"], Resource = "*" },
      { Effect = "Allow", Action = ["route53:ChangeResourceRecordSets"], Resource = "*" }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_failover" {
  role       = aws_iam_role.lambda_failover.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}
