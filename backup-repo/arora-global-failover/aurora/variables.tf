variable "db_engine" {
  description = "Aurora engine"
  type        = string
  default     = "aurora-mysql"
}

variable "engine_version" {
  description = "Engine version"
  type        = string
  default     = "8.0.mysql_aurora.3.04.0"
}

variable "instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.r5.large"
}

variable "db_name" {
  type    = string
  default = "mydb"
}

variable "db_username" {
  type    = string
  default = "admin"
}

variable "db_password" {
  description = "Master password"
  type        = string
}

variable "global_cluster_id" {
  type    = string
}

variable "primary_region" {}
variable "secondary_region" {}

variable "subnet_ids" {
  description = "List of subnet IDs for the DB subnet group"
  type        = list(string)
}
variable "primary_subnet_ids" {
  description = "List of subnet IDs for the primary region"
  type        = list(string)
}

variable "secondary_subnet_ids" {
  description = "List of subnet IDs for the secondary region"
  type        = list(string)
  
   
}
variable "secondary_vpc_id" {
  description = "The VPC ID for the secondary region"
  type        = string
}