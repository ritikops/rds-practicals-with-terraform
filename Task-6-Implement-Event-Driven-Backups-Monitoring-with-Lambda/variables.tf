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
variable "rds_instance_identifier" {
  description = "The identifier of the RDS instance"
  type        = string
}
variable "alert_email" {
  description = "The email address to receive RDS event notifications"
  type        = string
}
variable "master_username" {
  description = "The master username for the RDS instance"
  type        = string
}
variable "master_password" {
  description = "The master password for the RDS instance"
  type        = string
}
variable "db_instance_class" {
  description = "The instance class for the RDS instance"
  type        = string
}
variable "subnet_ids" {
  description = "The subnet IDs for the RDS instance"
  type        = list(string)
}
variable "security_group_id" {
  description = "The security group ID for the RDS instance"
  type        = string
}

variable "azs" {
  description = "The availability zones for the RDS instance"
  type        = list(string)
}
  