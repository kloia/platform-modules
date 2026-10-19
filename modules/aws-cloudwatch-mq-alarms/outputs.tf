output "alarm_arns" {
  description = "Alarm ARNs keyed by alarm type."
  value = merge(
    { for k, m in module.activemq : k => m.cloudwatch_metric_alarm_arn },
    { for k, m in module.rabbitmq : k => m.cloudwatch_metric_alarm_arn },
  )
}

output "engine_type" {
  description = "Broker engine, which decides the alarm set."
  value       = data.aws_mq_broker.this.engine_type
}
