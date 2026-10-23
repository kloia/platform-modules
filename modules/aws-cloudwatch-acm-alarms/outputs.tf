output "alarm_arns" {
  description = "Alarm ARNs keyed by alarm type."
  value       = { expiry = module.expiry.cloudwatch_metric_alarm_arn }
}

output "certificate_arn" {
  description = "Certificate alarmed on."
  value       = data.aws_acm_certificate.this.arn
}
