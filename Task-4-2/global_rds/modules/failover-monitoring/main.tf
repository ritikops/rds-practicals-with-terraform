# resource "aws_cloudwatch_event_rule" "failover_event" {
#   provider    = aws.primary
#   name        = "${var.cluster_identifier}-failover-event"
#   description = "Capture RDS failover events"

#   event_pattern = jsonencode({
#     source      = ["aws.rds"]
#     detail-type = ["RDS DB Cluster Event"]
#     detail = {
#       EventCategories = ["failover"]
#       SourceArn       = [var.primary_arn, var.replica_arn]
#     }
#   })
# }

# resource "aws_lambda_function" "failover_handler" {
#   provider      = aws.primary
#   filename      = "${path.module}/lambda/failover_handler.zip"
#   function_name = "${var.cluster_identifier}-failover-handler"
#   role          = aws_iam_role.lambda.arn
#   handler       = "main.lambda_handler"
#   runtime       = "python3.9"
#   timeout       = 120

#   environment {
#     variables = {
#       CLUSTER_ID     = var.global_cluster_id
#       PRIMARY_REGION = var.primary_region
#       REPLICA_REGION = var.replica_region
#       SNS_TOPIC_ARN  = var.sns_topic_arn
#       SLACK_WEBHOOK  = var.slack_webhook_url
#     }
#   }
# }

# resource "aws_lambda_permission" "allow_eventbridge" {
#   provider      = aws.primary
#   statement_id  = "AllowExecutionFromEventBridge"
#   action        = "lambda:InvokeFunction"
#   function_name = aws_lambda_function.failover_handler.function_name
#   principal     = "events.amazonaws.com"
#   source_arn    = aws_cloudwatch_event_rule.failover_event.arn
# }

# resource "aws_cloudwatch_event_target" "lambda_target" {
#   provider  = aws.primary
#   rule      = aws_cloudwatch_event_rule.failover_event.name
#   target_id = "SendToLambda"
#   arn       = aws_lambda_function.failover_handler.arn
# }
resource "aws_cloudwatch_event_rule" "failover" {
  name        = "${var.cluster_identifier}-failover-event"
  description = "Triggers when RDS failover is detected"

  event_pattern = jsonencode({
    source      = ["aws.rds"]
    detail-type = ["RDS DB Cluster Event"]
    detail = {
      EventCategories = ["failover"]
      SourceArn       = [var.primary_arn, var.replica_arn]
    }
  })
}

resource "aws_lambda_function" "failover_handler" {
  filename      = "${path.module}/failover_handler.zip"
  function_name = "${var.cluster_identifier}-failover-handler"
  role          = aws_iam_role.lambda.arn
  handler       = "failover_handler.lambda_handler"
  runtime       = "python3.9"
  timeout       = 120

  environment {
    variables = {
      CLUSTER_ID     = var.cluster_identifier
      PRIMARY_REGION = split(":", var.primary_arn)[3]
      REPLICA_REGION = split(":", var.replica_arn)[3]
      SLACK_WEBHOOK  = var.slack_webhook_url
      SNS_TOPIC_ARN  = var.sns_topic_arn
    }
  }
}

resource "aws_lambda_permission" "eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.failover_handler.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.failover.arn
}

resource "aws_cloudwatch_event_target" "lambda" {
  rule      = aws_cloudwatch_event_rule.failover.name
  target_id = "FailoverHandler"
  arn       = aws_lambda_function.failover_handler.arn
}