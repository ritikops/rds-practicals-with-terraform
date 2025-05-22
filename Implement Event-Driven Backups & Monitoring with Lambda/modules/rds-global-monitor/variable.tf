variable "function_name" {
  description = "Name of the Lambda function and associated resources"
  type        = string
  default     = "rds-global-cluster-monitor"
}

variable "backup_bucket_name" {
  description = "Name of the S3 bucket for backup exports"
  type        = string
}

variable "lambda_timeout" {
  description = "Lambda function timeout in seconds"
  type        = number
  default     = 60
}

variable "lambda_memory_size" {
  description = "Lambda function memory size in MB"
  type        = number
  default     = 128
}

variable "lambda_layers" {
  description = "List of Lambda layer ARNs to attach"
  type        = list(string)
  default     = []
}

variable "lambda_environment_variables" {
  description = "Additional environment variables for Lambda function"
  type        = map(string)
  default     = {}
}

variable "sns_topic_arn" {
  description = "ARN of existing SNS topic for alerts. Leave empty to create new"
  type        = string
  default     = ""
}

variable "kms_key_arn" {
  description = "ARN of existing KMS key for encryption. Leave empty to create new"
  type        = string
  default     = ""
}

variable "kms_key_deletion_window" {
  description = "Days to wait before deleting KMS key"
  type        = number
  default     = 10
}

variable "kms_key_rotation" {
  description = "Enable automatic rotation for KMS key"
  type        = bool
  default     = true
}

variable "kms_key_policy" {
  description = "Custom policy for KMS key. Leave empty for default"
  type        = string
  default     = ""
}

variable "create_export_role" {
  description = "Whether to create the RDS export role"
  type        = bool
  default     = true
}

variable "monitored_event_categories" {
  description = "List of RDS event categories to monitor"
  type        = list(string)
  default     = ["backup", "failover", "notification", "maintenance"]
}

variable "log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 30
}

variable "additional_lambda_policy_statements" {
  description = "Additional IAM policy statements for Lambda role"
  type        = list(any)
  default     = []
}