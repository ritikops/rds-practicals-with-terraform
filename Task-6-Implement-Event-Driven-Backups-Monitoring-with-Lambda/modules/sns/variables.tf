variable "topic_name" {}
variable "tags" {
  type = map(string)
}
variable "email" {
  description = "The email address to subscribe to the SNS topic"
  type        = string
  default     = "rikbusiness5@gmail.com"
}