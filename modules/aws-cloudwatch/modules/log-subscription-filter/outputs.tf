output "subscription_filter_specs" {
  value       = aws_cloudwatch_log_subscription_filter.this[*]
  description = "Subscription Filter Specs"
}
