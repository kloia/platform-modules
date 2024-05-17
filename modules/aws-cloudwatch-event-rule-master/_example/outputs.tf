output "arn" {
  value       = module.event-rule.*.arn
  description = "The ARN of the cloudwatch metric alarm."
}

output "tags" {
  value       = module.event-rule.tags
  description = "A mapping of tags to assign to the Cloudwatch Alarm."
}