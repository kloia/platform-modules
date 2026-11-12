output "alarm_arns" {
  description = "Alarm ARNs keyed by alarm type."
  value       = { for k, m in module.alarm : k => m.cloudwatch_metric_alarm_arn }
}

output "nodes" {
  description = "Cache nodes alarmed on."
  value       = local.nodes
}
