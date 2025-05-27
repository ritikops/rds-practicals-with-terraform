variable "cluster_name" {}
variable "primary_region" {}
variable "secondary_region" {}
variable "tags" {
  type = map(string)
}
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"

}

variable "subnet_cidrs" {
  description = "List of CIDR blocks for the subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "availability_zones" {
  description = "List of availability zones for the subnets"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}
# Add your variable declarations below

variable "primary_instance_count" {
  description = "Number of primary RDS cluster instances"
  type        = number
  default     = 1
}
variable "secondary_instance_class" {
  description = "The instance class for secondary RDS cluster instances"
  type        = string
}
variable "global_cluster_identifier" {
  description = "Global cluster identifier for RDS"
  type        = string
}

variable "primary_instance_class" {
  description = "Instance class for primary RDS cluster instances"
  type        = string
  default     = "db.r6g.large"
}

variable "engine" {
  description = "Database engine for RDS cluster instances"
  type        = string
  default     = "aurora-mysql"
}

variable "db_parameter_group_name" {
  description = "DB parameter group name for RDS cluster instances"
  type        = string
  default     = ""
}
variable "secondary_instance_count" {
  description = "Number of secondary (reader) instances to create in the secondary cluster"
  type        = number
  default     = 1
}
# Add your variable declarations below

variable "engine_version" {
  description = "The engine version for the RDS cluster"
  type        = string
}

variable "secondary_db_subnet_group_name" {
  description = "The subnet group name for the secondary RDS cluster"
  type        = string
}

variable "secondary_vpc_security_group_ids" {
  description = "List of VPC security group IDs for the secondary RDS cluster"
  type        = list(string)
}

variable "db_cluster_parameter_group_name" {
  description = "The DB cluster parameter group name for the secondary RDS cluster"
  type        = string
}