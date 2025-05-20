variable "db_engine" {
  description = "Aurora engine"
  default     = "aurora-mysql"
}

variable "engine_version" {
  description = "Engine version"
  default     = "5.7.mysql_aurora.2.10.0"
}

variable "instance_class" {
  description = "RDS instance class"
  default     = "db.r5.large"
}

variable "db_name" {
  default = "mydb"
}

variable "db_username" {
  default = "admin"
}

variable "db_password" {
  description = "Master password"
  default     = "password123"
}

variable "global_cluster_id" {
  default = "aurora-global-db"
}
