variable "region" {}
variable "role" {} # writer or replica
variable "vpc_cidr" {}
variable "subnet1_cidr" {}
variable "subnet2_cidr" {}
variable "availability_zone1" {}
variable "availability_zone2" {}

variable "db_engine" {
  default = "aurora-mysql"
}
variable "engine_version" {
  default = "5.7.mysql_aurora.2.11.4"
}
variable "instance_class" {
  default = "db.r5.large"
}
variable "master_username" {
  default = "admin"
}
variable "master_password" {
  default = "password1234"
}
variable "db_identifier" {
  default = "example-db"
}
variable "db_name" {
  default = "example_db"
}
variable "db_subnet_group_name" {
  default = "rds-subnet-group"
}
variable "sg_cidr_block" {
  default = "0.0.0.0/0"
}
variable "backup_window" {
  default = "03:00-04:00"
}
variable "global_cluster_id" {
  default = "global-cluster-demo"
}
variable "create_global_cluster" {
  default = false
}
variable "source_region" {
  default = ""
}
