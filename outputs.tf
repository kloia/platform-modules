output "alarm_arns" {
  description = "Alarm ARNs, keyed by `<load balancer>-target` / `<load balancer>-elb`."
  value       = { for k, m in module.alarm : k => m.cloudwatch_metric_alarm_arn }
}

output "load_balancer_arn_suffixes" {
  description = "Resolved `app/<name>/<id>` per load balancer name."
  value       = { for k, lb in data.aws_lb.this : k => lb.arn_suffix }
}
