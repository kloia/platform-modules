output "broker_id" {
  value       = join("", aws_mq_broker.default.*.id)
  description = "AmazonMQ broker ID"
}

output "broker_arn" {
  value       = join("", aws_mq_broker.default.*.arn)
  description = "AmazonMQ broker ARN"
}

output "broker_name" {
  value       = join("", aws_mq_broker.default.*.broker_name)
  description = "AmazonMQ broker name"
}

output "primary_console_url" {
  value       = try(aws_mq_broker.default[0].instances[0].console_url, "")
  description = "AmazonMQ active web console URL"
}

output "admin_username" {
  value       = local.mq_admin_user
  description = "AmazonMQ admin username"
}

output "admin_password" {
  value       = local.mq_admin_password
  description = "AmazonMQ admin password"
  sensitive   = true
}

output "application_username" {
  value       = local.mq_application_user
  description = "AmazonMQ application username"
}

output "application_password" {
  value       = local.mq_application_password
  description = "AmazonMQ application user password"
  sensitive   = true
}