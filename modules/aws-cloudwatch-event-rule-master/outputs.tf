#Module      : CLOUDWATCH METRIC ALARM
#Description : Terraform module creates Cloudwatch Alarm on AWS for monitoriing AWS services.
output "name" {
  value       = aws_cloudwatch_event_rule.default.*.name
  description = "The ID of the health check."
}

output "arn" {
  value       = aws_cloudwatch_event_rule.default.*.arn
  description = "The ARN of the cloudwatch metric alarm."
}

/* output "tags" {
  value       = var.tags
  description = "A mapping of tags to assign to the resource."
} */

