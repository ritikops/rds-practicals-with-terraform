variable "primary_region" {}
variable "secondary_region" {}
variable "cluster_name" {}
variable "snapshot_bucket_name" {}
variable "topic_name" {}
variable "lambda_role_name" {}
variable "lambda_function_name" {}
variable "tags" {
  type = map(string)
}
variable "global_cluster_identifier" {
  description = "The identifier for the global RDS cluster"
  type        = string
}
variable "kms_key_arn" {
  description = "The ARN of the KMS key to use for encryption/decryption in this IAM module."
  type        = string
}