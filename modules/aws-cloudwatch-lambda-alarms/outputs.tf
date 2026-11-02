output "alarm_arns" {
  description = "Alarm ARNs, keyed by `<function>-error-rate`, `<function>-throttles` and `<function>-duration`."
  value       = { for k, m in module.alarm : k => m.cloudwatch_metric_alarm_arn }
}

output "effective_settings" {
  description = "Per function, the values in force after overrides, including the timeout read from the function."
  value       = local.settings
}
