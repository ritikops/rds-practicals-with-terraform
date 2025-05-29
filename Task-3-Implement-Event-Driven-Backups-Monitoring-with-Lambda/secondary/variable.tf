variable "db_engine" {
  description = "The database engine (aurora-mysql or aurora-postgresql)"
  type        = string
  default     = "aurora-mysql"
}

variable "engine_version" {
  description = "Engine version"
  type        = string
  default     = "5.7.mysql_aurora.2.11.4"
}

variable "instance_class" {
  description = "Instance class for RDS"
  type        = string
  default     = "db.r5.large"
}

variable "kms_key_id" {
  description = "KMS Key ID for encryption"
  type        = string
  default     = ""
}

variable "db_subnet_group_name" {
  description = "DB Subnet Group name"
  type        = string
  default     = "rds-secondary-subnet-group"
}

variable "vpc_security_group_ids" {
  description = "List of security group IDs"
  type        = list(string)
  default     = []
}

variable "backup_window" {
  description = "Preferred backup window"
  type        = string
  default     = "03:00-04:00"
}

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

variable "db_name" {
  description = "Database name"
  type        = string
  default     = "example_db"
}
# output "primary_cluster_id" {
#   value = module.primary.cluster_id
# }

# output "primary_cluster_arn" {
#   value = module.primary.cluster_arn
# }

# output "secondary_cluster_id" {
#   value = module.secondary.cluster_id
# }

# output "secondary_cluster_arn" {
#   value = module.secondary.cluster_arn
# }
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