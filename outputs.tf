output "alarm_arns" {
  description = "Alarm ARNs, keyed by alarm name."
  value = merge(
    { for k, m in module.health : m.cloudwatch_metric_alarm_id => m.cloudwatch_metric_alarm_arn },
    { for k, m in module.port_allocation : m.cloudwatch_metric_alarm_id => m.cloudwatch_metric_alarm_arn },
  )
}

output "load_balancer_arn_suffixes" {
  description = "Resolved `net/<name>/<id>` per load balancer name."
  value       = { for k, lb in data.aws_lb.this : k => lb.arn_suffix }
}
