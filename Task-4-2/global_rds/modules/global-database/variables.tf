variable "cluster_identifier" {
  description = "The identifier for the global cluster"
  type        = string
}
variable "engine_version" {
  description = "The engine version to use for the RDS global cluster"
  type        = string
}