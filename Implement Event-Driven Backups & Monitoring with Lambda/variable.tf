variable "alert_email" {
  description = "Email address for receiving alerts"
  type        = string
}

variable "slack_webhook_url" {
  description = "Slack webhook URL for notifications (optional)"
  type        = string
  default     = ""
}