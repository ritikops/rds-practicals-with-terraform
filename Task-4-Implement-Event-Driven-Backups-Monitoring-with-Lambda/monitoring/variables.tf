# variable "backup_bucket" {
#   description = "S3 bucket for backup exports"
#   type        = string
# }

# variable "sns_topic_arn" {
#   description = "ARN of SNS topic for alerts"
#   type        = string
# }

# variable "primary_region" {
#   description = "AWS region for primary cluster"
#   type        = string
#   default     = "us-east-1"
# }

# variable "secondary_region" {
#   description = "AWS region for secondary cluster"
#   type        = string
#   default     = "us-west-2"
# }
variable "backup_bucket" {
  description = "S3 bucket for backup exports"
  type        = string
}

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

variable "primary_region" {
  description = "Primary region for monitoring"
  type        = string
  default     = "us-east-1"
}

variable "secondary_region" {
  description = "Secondary region"
  type        = string
  default     = "eu-west-1"
}