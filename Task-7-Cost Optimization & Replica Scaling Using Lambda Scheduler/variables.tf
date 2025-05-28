variable "vpc_cidr" {}
variable "private_subnets_cidr" {
  type = list(string)
}
variable "db_username" {}
variable "db_password" {}
variable "db_instance_class" {}
variable "initial_read_replica_count" {}
