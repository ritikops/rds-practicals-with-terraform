variable "global_cluster_id" {
  description = "Global cluster ID"
  type        = string
  default     = "global-cluster-demo"
}

variable "db_identifier" {
  description = "DB identifier"
  type        = string
  default     = "example-db"
}

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
# Define variables for the monitoring module

variable "primary_cluster_id" {
  description = "The ID of the primary cluster"
  type        = string
}

variable "primary_cluster_arn" {
  description = "The ARN of the primary cluster"
  type        = string
}

variable "secondary_cluster_id" {
  description = "The ID of the secondary cluster"
  type        = string
}

variable "secondary_cluster_arn" {
  description = "The ARN of the secondary cluster"
  type        = string
}

# variable "backup_bucket" {
#   description = "The S3 bucket for backups"
#   type        = string
# }

# variable "sns_topic_arn" {
#   description = "The ARN of the SNS topic"
#   type        = string
# }

# variable "slack_webhook_url" {
#   description = "The Slack webhook URL"
#   type        = string
# }

# variable "replica_lag_threshold" {
#   description = "The threshold for replica lag"
#   type        = number
# }
