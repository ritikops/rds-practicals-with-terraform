
variable "lambda_role_arn" {
  description = "IAM role ARN for Lambda execution"
  type        = string
}

variable "db_cluster_id" {
  description = "ID of the RDS cluster"
  type        = string
}

variable "instance_class" {
  description = "RDS instance class for scaling"
  type        = string
  default     = "db.t3.medium"
}

variable "cloudwatch_event_arn" {
  description = "ARN of the CloudWatch Event Rule that will trigger Lambda"
  type        = string
}
