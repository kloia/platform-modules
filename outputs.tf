output "alarm_arns" {
  description = "Alarm ARNs, keyed by API name."
  value       = { for k, m in module.error_rate : k => m.cloudwatch_metric_alarm_arn }
}
