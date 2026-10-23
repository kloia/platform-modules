output "alarm_arns" {
  description = "Alarm ARNs keyed by alarm type."
  value = merge(
    { for k, m in module.worst : k => m.cloudwatch_metric_alarm_arn },
    { for k, m in module.pct : k => m.cloudwatch_metric_alarm_arn },
    { for m in module.connections : "connections" => m.cloudwatch_metric_alarm_arn },
    { for m in module.global_lag : "global-lag" => m.cloudwatch_metric_alarm_arn },
  )
}

output "instances" {
  description = "Instances alarmed on, with their class."
  value       = local.class
}
