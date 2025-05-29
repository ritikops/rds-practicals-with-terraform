variable "lambda_role_name" {}
variable "s3_bucket_arn" {}
variable "sns_topic_arn" {}

variable "snapshot_export_bucket" {
  description = "The name of the S3 bucket for snapshot exports"
  type        = string
}

variable "tags" {
  type = map(string)
}

variable "kms_key_arn" {
  description = "ARN of the KMS key to use for encryption/decryption in this IAM module."
  type        = string
}
