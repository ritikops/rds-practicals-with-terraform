output "scale_up_event_rule_arn" {
  description = "ARN of the scale-up CloudWatch event rule"
  value       = aws_cloudwatch_event_rule.scale_schedule_up.arn
}

output "scale_down_event_rule_arn" {
  description = "ARN of the scale-down CloudWatch event rule"
  value       = aws_cloudwatch_event_rule.scale_schedule_down.arn
}