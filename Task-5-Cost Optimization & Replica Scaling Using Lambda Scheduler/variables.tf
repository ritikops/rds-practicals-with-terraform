# variable "db_instance_identifier" {
#   description = "The identifier of the RDS DB instance."
#   type        = string
# }

# variable "read_replica_instance_class" {
#   description = "The instance class for the read replicas."
#   type        = string
#   default     = "db.t3.medium"
# }

# variable "scale_up_schedule_expression" {
#   description = "Cron expression for scaling up read replicas."
#   type        = string
#   default     = "cron(0 9 * * ? *)" # Every day at 9 AM UTC
# }

# variable "scale_down_schedule_expression" {
#   description = "Cron expression for scaling down read replicas."
#   type        = string
#   default     = "cron(0 19 * * ? *)" # Every day at 7 PM UTC
# }

variable "db_instance_identifier" {
  description = "The identifier of the RDS DB instance."
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9-]*$", var.db_instance_identifier))
    error_message = "The identifier must start with a letter and contain only letters, numbers, and hyphens."
  }
}

variable "read_replica_instance_class" {
  description = "The instance class for the read replicas."
  type        = string
  default     = "db.t3.medium"
  validation {
    condition     = contains(["db.t3.micro", "db.t3.small", "db.t3.medium", "db.t3.large"], var.read_replica_instance_class)
    error_message = "The instance class must be one of the following: db.t3.micro, db.t3.small, db.t3.medium, db.t3.large."
  }
}

variable "scale_up_schedule_expression" {
  description = "Cron expression for scaling up read replicas."
  type        = string
  default     = "cron(0 9 * * ? *)"
  validation {
    condition     = can(regex("cron\\(.*\\)", var.scale_up_schedule_expression))
    error_message = "The schedule expression must be a valid cron expression."
  }
}

variable "scale_down_schedule_expression" {
  description = "Cron expression for scaling down read replicas."
  type        = string
  default     = "cron(0 19 * * ? *)"
  validation {
    condition     = can(regex("cron\\(.*\\)", var.scale_down_schedule_expression))
    error_message = "The schedule expression must be a valid cron expression."
  }
}

variable "desired_read_replica_count" {
  description = "Desired number of read replicas during business hours."
  type        = number
  default     = 2
  validation {
    condition     = var.desired_read_replica_count >= 0
    error_message = "The desired number of read replicas must be a non-negative integer."
  }
}
# variable "desired_read_replica_count" {
#   description = "Desired number of read replicas during business hours."
#   type        = number
#   default     = 2
# }
