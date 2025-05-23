variable "backup_bucket" {
  description = "S3 bucket for backup exports"
  type        = string
}

variable "sns_topic_arn" {
  description = "ARN of SNS topic for alerts"
  type        = string
}

variable "primary_region" {
  description = "AWS region for primary cluster"
  type        = string
  default     = "us-east-1"
}

variable "secondary_region" {
  description = "AWS region for secondary cluster"
  type        = string
  default     = "us-west-2"
}