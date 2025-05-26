
variable "backup_bucket" {
  description = "S3 bucket for backups"
  type        = string
  validation {
    condition     = can(regex("^[a-z0-9.-]{3,63}$", var.backup_bucket))
    error_message = "S3 bucket name must be valid (lowercase, 3-63 chars)"
  }
}
variable "backup_retention_days" {
  description = "Number of days to retain backups in S3"
  type        = number
  default     = 90
}

variable "kms_key_arn" {
  description = "KMS key ARN for encryption"
  type        = string
}
variable "primary_cluster_id" {
  description = "The ID of the primary RDS cluster"
  type        = string
}

variable "primary_cluster_arn" {
  description = "The ARN of the primary RDS cluster"
  type        = string
}

variable "secondary_cluster_id" {
  description = "The ID of the secondary RDS cluster"
  type        = string
}

variable "secondary_cluster_arn" {
  description = "The ARN of the secondary RDS cluster"
  type        = string
}

# variable "backup_bucket" {
#   description = "S3 bucket for backup exports"
#   type        = string
# }

variable "sns_topic_arn" {
  description = "ARN of SNS topic for alerts"
  type        = string
}

variable "slack_webhook_url" {
  description = "Slack webhook URL for alerts"
  type        = string
  default     = ""
  sensitive   = true
}

variable "replica_lag_threshold" {
  description = "Threshold in seconds for replica lag alerts"
  type        = number
  default     = 60
}
variable "primary_kms_key_arn" {
  description = "ARN of primary KMS key"
  type        = string
}

variable "secondary_kms_key_arn" {
  description = "ARN of secondary KMS key"
  type        = string
}
