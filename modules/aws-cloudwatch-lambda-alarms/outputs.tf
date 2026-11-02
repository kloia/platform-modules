output "alarm_arns" {
  description = "Alarm ARNs, keyed by `<function>-error-rate`, `<function>-throttles` and `<function>-duration`."
  value = merge(
    { for k, m in module.error_rate : "${k}-error-rate" => m.cloudwatch_metric_alarm_arn },
    { for k, m in module.throttles : "${k}-throttles" => m.cloudwatch_metric_alarm_arn },
    { for k, m in module.duration : "${k}-duration" => m.cloudwatch_metric_alarm_arn },
  )
}

output "effective_settings" {
  description = "Per function, the values in force after overrides, including the timeout read from the function."
  value       = local.settings
}
