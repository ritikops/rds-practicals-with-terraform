variable "function_name" {}
variable "role_arn" {}
variable "bucket_name" {}
variable "sns_topic_arn" {}
variable "tags" {
  type = map(string)
}
