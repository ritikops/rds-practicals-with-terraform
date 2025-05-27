variable "lambda_role_name" {}
variable "s3_bucket_arn" {}
variable "sns_topic_arn" {}
variable "tags" {
  type = map(string)
}
