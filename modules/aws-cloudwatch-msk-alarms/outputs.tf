output "alarm_arns" {
  description = "Alarm ARNs keyed by alarm type."
  value = merge(
    { for k, m in module.cluster : k => m.cloudwatch_metric_alarm_arn },
    { for k, m in module.broker : k => m.cloudwatch_metric_alarm_arn },
    { cpu = module.cpu.cloudwatch_metric_alarm_arn },
  )
}

output "brokers" {
  description = "Broker IDs alarmed on."
  value       = local.brokers
}
