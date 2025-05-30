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

# variable "sns_topic_arn" {
#   description = "ARN of SNS topic for alerts"
#   type        = string
# }

variable "slack_webhook_url" {
  description = "Slack webhook URL for alerts"
  type        = string
  default     = "https://iqinfinite.webhook.office.com/webhookb2/f20e6eb8-982c-4024-9e60-a2e46a27cb80@b6859703-4fa9-46af-b7a6-c453ed19dd3d/IncomingWebhook/8eb023620aaf41c1b0ab8dad6e8bf13d/97973af2-3701-4b6c-b775-bb789e97f515/V2ZA1fzbW-5BcQA1BSSFh3mV22Eeri1LLpyBvj2P2H3n81"
  sensitive   = true
}

# variable "replica_lag_threshold" {
#   description = "Threshold in seconds for replica lag alerts"
#   type        = number
#   default     = 60
# }
variable "replica_lag_threshold" {
  description = "Replica lag threshold in seconds"
  type        = number
  default     = 60
  validation {
    condition     = var.replica_lag_threshold >= 30 && var.replica_lag_threshold <= 300
    error_message = "Threshold must be between 30-300 seconds"
  }
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
variable "primary_kms_key_arn" {
  description = "ARN of primary KMS key"
  type        = string
}

variable "secondary_kms_key_arn" {
  description = "ARN of secondary KMS key"
  type        = string
}
variable "sns_topic_arn" {
  description = "ARN of SNS topic for alerts (must be full ARN format)"
  type        = string
  validation {
    condition     = can(regex("^arn:aws:sns:[a-z0-9-]+:[0-9]{12}:.+$", var.sns_topic_arn))
    error_message = "SNS topic ARN must be in format: arn:aws:sns:region:account-id:topic-name"
  }
}
variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  validation {
    condition     = contains(["db.t3.medium", "db.r5.large", "db.r5.xlarge"], var.db_instance_class)
    error_message = "Use a production-appropriate instance class"
  }
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
