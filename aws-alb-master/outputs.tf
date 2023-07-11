#------------------------------------------------------------------------------
# APPLICATION LOAD BALANCER
#------------------------------------------------------------------------------
output "aws_lb_lb_id" {
  description = "The ARN of the load balancer (matches arn)."
  value       = aws_lb.lb[0].id
}

output "aws_lb_lb_arn" {
  description = "The ARN of the load balancer (matches id)."
  value       = aws_lb.lb[0].arn
}

output "aws_lb_lb_arn_suffix" {
  description = "The ARN suffix for use with CloudWatch Metrics."
  value       = aws_lb.lb[0].arn_suffix
}

output "aws_lb_lb_dns_name" {
  description = "The DNS name of the load balancer."
  value       = aws_lb.lb[0].dns_name
}

output "aws_lb_lb_zone_id" {
  description = "The canonical hosted zone ID of the load balancer (to be used in a Route 53 Alias record)."
  value       = aws_lb.lb[0].zone_id
}

#------------------------------------------------------------------------------
# AWS LOAD BALANCER - Target Groups
#------------------------------------------------------------------------------

output "target_group_arns" {
  description = "ARNs of the target groups. Useful for passing to your Auto Scaling group"
  value       = aws_lb_target_group.main[*].arn
}

output "target_group_arn_suffixes" {
  description = "ARN suffixes of our target groups - can be used with CloudWatch"
  value       = aws_lb_target_group.main[*].arn_suffix
}

output "target_group_names" {
  description = "Name of the target group. Useful for passing to your CodeDeploy Deployment Group"
  value       = aws_lb_target_group.main[*].name
}

output "target_group_attachments" {
  description = "ARNs of the target group attachment IDs"
  value       = { for k, v in aws_lb_target_group_attachment.this : k => v.id }
}

#------------------------------------------------------------------------------
# AWS LOAD BALANCER - Listeners
#------------------------------------------------------------------------------
output "http_tcp_listener_arns" {
  description = "The ARN of the TCP and HTTP load balancer listeners created"
  value       = aws_lb_listener.frontend_http_tcp[*].arn
}

output "http_tcp_listener_ids" {
  description = "The IDs of the TCP and HTTP load balancer listeners created"
  value       = aws_lb_listener.frontend_http_tcp[*].id
}

output "https_listener_arns" {
  description = "The ARNs of the HTTPS load balancer listeners created"
  value       = aws_lb_listener.frontend_https[*].arn
}

output "https_listener_ids" {
  description = "The IDs of the load balancer listeners created"
  value       = aws_lb_listener.frontend_https[*].id
}

#------------------------------------------------------------------------------
# S3 LB Logging Bucket
#------------------------------------------------------------------------------
output "lb_logs_s3_bucket_id" {
  description = "LB Logging S3 Bucket ID"
  value       = var.enable_s3_logs ? module.lb_logs_s3[0].s3_bucket_id : null
}

output "lb_logs_s3_bucket_arn" {
  description = "LB Logging S3 Bucket ARN"
  value       = var.enable_s3_logs ? module.lb_logs_s3[0].s3_bucket_arn : null
}