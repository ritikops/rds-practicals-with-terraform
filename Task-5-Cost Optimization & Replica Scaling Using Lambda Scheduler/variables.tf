variable "db_instance_identifier" {
  description = "The identifier of the RDS DB instance."
  type        = string
}

variable "read_replica_instance_class" {
  description = "The instance class for the read replicas."
  type        = string
  default     = "db.t3.medium"
}

variable "scale_up_schedule_expression" {
  description = "Cron expression for scaling up read replicas."
  type        = string
  default     = "cron(0 9 * * ? *)" # Every day at 9 AM UTC
}

variable "scale_down_schedule_expression" {
  description = "Cron expression for scaling down read replicas."
  type        = string
  default     = "cron(0 19 * * ? *)" # Every day at 7 PM UTC
}

variable "desired_read_replica_count" {
  description = "Desired number of read replicas during business hours."
  type        = number
  default     = 2
}
