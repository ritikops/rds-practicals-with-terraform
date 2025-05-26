output "rds_global_cluster_id" {
  value = module.rds.global_cluster_id
}

output "sns_topic_arn" {
  value = module.notifications.sns_topic_arn
}

output "lambda_function_name" {
  value = module.lambda.rds_monitor_function_name
}
