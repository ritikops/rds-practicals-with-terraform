# output "db_cluster_id" {
#   value = module.rds.db_cluster_id
# }
# output "lambda_arn" {
#   value = module.lambda.lambda_arn
# }
output "vpc_id" {
  description = "ID of the created VPC"
  value       = module.vpc.vpc_id
}

output "subnet_ids" {
  description = "Private subnet IDs"
  value       = module.vpc.private_subnet_ids
}

output "db_cluster_endpoint" {
  description = "RDS cluster writer endpoint"
  value       = module.rds.endpoint
}

output "db_cluster_id" {
  description = "ID of the RDS cluster"
  value       = module.rds.db_cluster_id
}

output "lambda_function_name" {
  description = "Name of the Lambda function"
  value       = module.lambda.lambda_name
}

