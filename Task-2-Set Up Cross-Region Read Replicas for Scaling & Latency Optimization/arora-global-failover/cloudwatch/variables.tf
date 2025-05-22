variable "global_cluster_id" {
  type = string
}
variable "lambda_function_arn" {
  description = "ARN of the Lambda function to trigger"
  type        = string
}

variable "lambda_function_name" {
  description = "Name of the Lambda function to trigger"
  type        = string
}
variable "primary_health_check_id" {
  description = "The Route53 health check ID for the primary Aurora cluster"

  type        = string
}
