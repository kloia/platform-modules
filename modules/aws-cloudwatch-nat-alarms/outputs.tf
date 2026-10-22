output "alarm_arns" {
  description = "Alarm ARNs keyed by alarm type."
  value       = { port-allocation-errors = module.port_allocation.cloudwatch_metric_alarm_arn }
}

output "nat_gateways" {
  description = "NAT gateway IDs alarmed on."
  value       = local.gateways
}
