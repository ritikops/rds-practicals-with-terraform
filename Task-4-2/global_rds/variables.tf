# variable "primary_region" {
#   description = "Primary AWS region for the global database"
#   type        = string
#   default     = "us-east-1"
# }

# variable "replica_region" {
#   description = "Replica AWS region for the global database"
#   type        = string
#   default     = "eu-west-1"
# }

# variable "cluster_identifier" {
#   description = "Identifier for the global database cluster"
#   type        = string
# }

# variable "engine_version" {
#   description = "Aurora engine version"
#   type        = string
#   default     = "5.7.mysql_aurora.2.11.2"
# }

# variable "instance_class" {
#   description = "Instance class for database instances"
#   type        = string
#   default     = "db.r5.large"
# }

# variable "vpc_security_group_ids" {
#   description = "List of VPC security group IDs"
#   type        = list(string)
# }

# variable "db_subnet_group_name" {
#   description = "DB subnet group name"
#   type        = string
# }

# variable "domain_name" {
#   description = "Route53 domain name for failover routing"
#   type        = string
# }

# variable "sns_topic_arn" {
#   description = "ARN of SNS topic for alerts"
#   type        = string
#   default     = ""
# }

# variable "slack_webhook_url" {
#   description = "Slack webhook URL for notifications"
#   type        = string
#   default     = ""
#   sensitive   = true
# }
# variable "primary_region" {
#   description = "The primary AWS region"
#   type        = string
# }

# variable "environment" {
#   description = "Deployment environment (e.g., dev, prod)"
#   type        = string
# }
variable "primary_region" {
  description = "Primary AWS region for RDS cluster"
  type        = string
  default     = "us-east-1"
}

variable "replica_region" {
  description = "Replica AWS region for RDS cluster"
  type        = string
  default     = "eu-west-1"
}

variable "cluster_prefix" {
  description = "Prefix for RDS cluster identifiers"
  type        = string
  default     = "global-db"
}

variable "environment" {
  description = "Deployment environment (dev/stage/prod)"
  type        = string
  default     = "prod"
}

variable "engine_version" {
  description = "Aurora MySQL engine version"
  type        = string
  default     = "5.7.mysql_aurora.2.11.2"
}

variable "instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.r5.large"
}

variable "vpc_security_group_ids" {
  description = "List of VPC security group IDs"
  type        = list(string)
}

variable "db_subnet_group_name" {
  description = "DB subnet group name"
  type        = string
}

variable "domain_name" {
  description = "Route53 domain name for failover routing"
  type        = string
}

variable "master_username" {
  description = "Master username for RDS"
  type        = string
  sensitive   = true
}

variable "master_password" {
  description = "Master password for RDS"
  type        = string
  sensitive   = true
}

variable "slack_webhook_url" {
  description = "Slack webhook URL for notifications"
  type        = string
  sensitive   = true
  default     = ""
}

variable "sns_topic_arn" {
  description = "ARN of SNS topic for alerts"
  type        = string
  default     = ""
}