output "alarm_arns" {
  description = "Alarm ARNs keyed by alarm type."
  value       = { tunnel-down = module.tunnel_down.cloudwatch_metric_alarm_arn }
}
