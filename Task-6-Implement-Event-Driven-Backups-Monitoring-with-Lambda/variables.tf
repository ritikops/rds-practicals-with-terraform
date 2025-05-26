variable "project_name" {
  description = "The name of the project"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "dev"
}

variable "account_id" {
  description = "AWS account ID"
  type        = string
}

variable "kms_key_id" {
  description = "KMS key ID for snapshot export encryption"
  type        = string
}

variable "export_role_arn" {
  description = "IAM Role ARN for exporting RDS snapshots"
  type        = string
}

variable "bucket_name" {
  description = "S3 bucket to store RDS snapshot exports"
  type        = string
}

variable "sns_topic_arn" {
  description = "SNS topic ARN for RDS event notifications"
  type        = string
}
