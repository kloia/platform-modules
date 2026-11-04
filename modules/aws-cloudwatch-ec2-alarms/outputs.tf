output "alarm_arns" {
  description = "Alarm ARNs keyed by alarm type."
  value       = { status-check-failed = module.status_check.cloudwatch_metric_alarm_arn }
}

output "instances" {
  description = "Instance IDs alarmed on."
  value       = local.instances
}
