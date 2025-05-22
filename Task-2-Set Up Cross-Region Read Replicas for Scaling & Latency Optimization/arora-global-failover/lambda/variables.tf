variable "primary_region" {
  type = string
}

variable "secondary_region" {
  type = string
}

variable "global_cluster_id" {
  type = string
}

variable "hosted_zone_id" {
  type = string
}

variable "db_hostname" {
  type = string
}
variable "function_name" {}
variable "secondary_cluster_id" {
  description = "The ID of the secondary Aurora cluster"
  type        = string
}