output "alarm_arns" {
  description = "Alarm ARNs, keyed by `<resource>-<alarm>`."
  value       = { for k, m in module.alarm : k => m.cloudwatch_metric_alarm_arn }
}
