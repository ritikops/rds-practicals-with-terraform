# variable "vpc_cidr" {}
# variable "private_subnets_cidr" {
#   type = list(string)
# }
# variable "db_username" {}
# variable "db_password" {}
# variable "db_instance_class" {}
# variable "initial_read_replica_count" {}
# variable "vpc_cidr" {
#   default = "10.0.0.0/16"
# }
# variable "private_subnets_cidr" {
#   type    = list(string)
#   default = ["10.0.3.0/24", "10.0.4.0/24"]
# }
# variable "db_username" {
#   default = "admin"
# }
# variable "db_password" {
#   default = "ChangeMe123!"
# }
# variable "db_instance_class" {
#   default = "db.t3.medium"
# }
# variable "initial_read_replica_count" {
#   default = 1
# }
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "private_subnets_cidr" {
  description = "List of private subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
}

variable "db_username" {
  description = "Master username for the RDS cluster"
  type        = string
  default     = "admin"
}

variable "db_password" {
  description = "Master password for the RDS cluster"
  type        = string
  default     = "ChangeMe123!"
  sensitive   = true
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
