variable "function_name" {}
variable "role_arn" {}
variable "bucket_name" {}
variable "sns_topic_arn" {}
variable "tags" {
  type = map(string)
}

variable "kms_key_id" {
  description = "KMS key ID or ARN for RDS export. Default is alias/aws/s3."
  type        = string
  default     = "alias/aws/s3"
}

variable "export_role_arn" {
  description = "ARN of the IAM role for RDS export."
  type        = string
}

variable "slack_webhook_url" {
  description = "(Optional) Slack webhook URL for notifications."
  type        = string
  default     = ""
}
