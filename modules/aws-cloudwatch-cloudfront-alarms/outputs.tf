output "alarm_arns" {
  description = "Alarm ARNs, keyed by distribution label."
  value       = { for k, m in module.alarm : k => m.cloudwatch_metric_alarm_arn }
}

output "distribution_domain_names" {
  description = "Resolved domain name per distribution label."
  value       = { for k, d in data.aws_cloudfront_distribution.this : k => d.domain_name }
}
