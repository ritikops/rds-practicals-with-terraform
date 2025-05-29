variable "db_username" {
  description = "Master username for RDS cluster"
  type        = string
}

variable "db_password" {
  description = "Master password for RDS cluster"
  type        = string
  sensitive   = true
}

variable "db_name" {
  description = "Initial database name"
  type        = string
}

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.medium"
}

variable "initial_read_replica_count" {
  description = "Initial number of read replicas"
  type        = number
  default     = 1
}

variable "db_sg_id" {
  description = "Security group ID for RDS"
  type        = string
}

variable "subnet_group_name" {
  description = "Subnet group name for RDS"
  type        = string
}
variable "subnet_ids" {
  description = "List of subnet IDs for RDS subnet group"
  type        = list(string)
}
