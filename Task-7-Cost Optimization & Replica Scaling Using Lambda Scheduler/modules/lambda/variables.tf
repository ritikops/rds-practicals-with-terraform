
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

variable "endpoint" {
  description = "Endpoint of the RDS cluster"
  type        = string
}
variable "scale_up_event_rule_arn" {
  description = "ARN of the scale-up CloudWatch event rule"
  type        = string
}

variable "scale_down_event_rule_arn" {
  description = "ARN of the scale-down CloudWatch event rule"
  type        = string
}