resource "aws_iam_role" "lambda_exec" {
  name = var.lambda_role_name
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_policy" "lambda_policy" {
  name = "${var.lambda_role_name}-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "rds:DescribeDBSnapshots",
          "rds:StartExportTask",
          "rds:DescribeExportTasks",
          "rds:CancelExportTask"

        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action = [
          "s3:PutObject",
          "s3:GetObject"
        ]
        Effect   = "Allow"
        Resource = "${var.s3_bucket_arn}/*"
      },
      {
        Action   = "sns:Publish"
        Effect   = "Allow"
        Resource = var.sns_topic_arn
      },
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_attach" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}
resource "aws_iam_role" "rds_export_role" {
  name = "RDSExportRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "export.rds.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}


resource "aws_iam_policy" "rds_export_policy" {
  name = "RDSExportToS3Policy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "rds:StartExportTask",
          "rds:DescribeDBSnapshots",
          "rds:DescribeExportTasks"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "s3:PutObject",
          "s3:GetBucketLocation",
          "s3:ListBucket"
        ],
        Resource = [
          "arn:aws:s3:::${var.snapshot_export_bucket}",
          "arn:aws:s3:::${var.snapshot_export_bucket}/*"
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:GenerateDataKey"
        ],
        Resource = var.kms_key_arn
      }
    ]
  })
}
resource "aws_iam_role_policy_attachment" "attach_export_policy" {
  role       = aws_iam_role.rds_export_role.name
  policy_arn = aws_iam_policy.rds_export_policy.arn
}
