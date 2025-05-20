
# variable "primary_region"         { default = "us-east-1" }
# variable "secondary_region"       { default = "us-west-2" }
# variable "db_engine" {
#   description = "Aurora engine"
#   default     = "aurora-mysql"
# }
# variable "engine_version" {
#   description = "Engine version"
#   default     = "5.7.mysql_aurora.2.10.0"
# }
# variable "instance_class" {
#   description = "RDS instance class"
#   default     = "db.r5.large"
# }
# variable "db_name"                { default = "mydb" }
# variable "db_username"            { default = "admin" }
# variable "db_password"            { description = "Master password" }
# variable "global_cluster_id"      { default = "aurora-global-db" }
# variable "hosted_zone_id"         { description = "Route53 zone ID" }
# variable "db_hostname"            { default = "db.example.com" }

variable "primary_region" {
  description = "The primary AWS region"
  type        = string
  default     = "us-east-1"
}

variable "secondary_region" {
  description = "The secondary AWS region"
  type        = string
  default     = "us-west-2"
}

variable "db_engine" {
  description = "Aurora engine"
  type        = string
  default     = "aurora-mysql"
}

variable "engine_version" {
  description = "Engine version"
  type        = string
  default     = "5.7.mysql_aurora.2.10.0"
}

variable "instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.r5.large"
}

variable "db_name" {
  description = "Database name"
  type        = string
  default     = "mydb"
}

variable "db_username" {
  description = "Master username"
  type        = string
  default     = "admin"
}

variable "db_password" {
  description = "Master password"
  type        = string
}

variable "global_cluster_id" {
  description = "The global cluster identifier"
  type        = string
  default     = "aurora-global-db"
}

variable "hosted_zone_id" {
  description = "Route53 Hosted Zone ID"
  type        = string
}

variable "db_hostname" {
  description = "The DNS record name for the DB"
  type        = string
  default     = "db.example.com"
}