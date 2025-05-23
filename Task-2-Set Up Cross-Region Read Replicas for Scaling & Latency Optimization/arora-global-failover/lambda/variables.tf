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
variable "global_cluster_identifier" {
  description = "The identifier of the RDS global cluster"
  type        = string
}
variable "primary_cluster_identifier" {
  description = "The identifier of the primary RDS cluster"
  type        = string
}
variable "replica_cluster_identifier" {
  description = "The identifier of the replica RDS cluster"
  type        = string
}
variable "replica_region" {
  description = "The AWS region of the replica cluster"
  type        = string
}