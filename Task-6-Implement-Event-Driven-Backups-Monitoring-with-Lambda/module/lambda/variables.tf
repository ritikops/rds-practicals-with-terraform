variable "snapshot_s3_bucket" {
  type = string
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
