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