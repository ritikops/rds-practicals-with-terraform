variable "snapshot_s3_bucket" {
  type = string
}

variable "rds_instance_identifier" {
  description = "The identifier of the RDS instance"
  type        = string
}

variable "rds_global_cluster_id" {
  type = string
}

variable "sns_topic_arn" {
  type = string
}
variable "kms_key_id" {
  type = string
}

variable "export_role_arn" {
  type = string
}
variable "rds_instance_identifier" {
  type = string
}