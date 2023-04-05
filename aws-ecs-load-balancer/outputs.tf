#------------------------------------------------------------------------------
# APPLICATION LOAD BALANCER
#------------------------------------------------------------------------------
output "aws_lb_lb_id" {
  description = "The ARN of the load balancer (matches arn)."
  value       = aws_lb.lb.id
}

output "aws_lb_lb_arn" {
  description = "The ARN of the load balancer (matches id)."
  value       = aws_lb.lb.arn
}

output "aws_lb_lb_name" {
  description = "The ARN of the load balancer (matches id)."
  value       = aws_lb.lb.arn
}

output "aws_lb_lb_arn_suffix" {
  description = "The ARN suffix for use with CloudWatch Metrics."
  value       = aws_lb.lb.arn_suffix
}

output "aws_lb_lb_dns_name" {
  description = "The DNS name of the load balancer."
  value       = aws_lb.lb.dns_name
}

output "aws_lb_lb_zone_id" {
  description = "The canonical hosted zone ID of the load balancer (to be used in a Route 53 Alias record)."
  value       = aws_lb.lb.zone_id
}

#------------------------------------------------------------------------------
# AWS LOAD BALANCER - Target Groups
#------------------------------------------------------------------------------
output "lb_http_tgs_ids" {
  description = "List of HTTP Target Groups IDs"
  value       = [for tg in aws_lb_target_group.lb_http_tgs : tg.id]
}

output "lb_http_tgs_arns" {
  description = "List of HTTP Target Groups ARNs"
  value       = [for tg in aws_lb_target_group.lb_http_tgs : tg.arn]
}

output "lb_http_tgs_names" {
  description = "List of HTTP Target Groups Names"
  value       = [for tg in aws_lb_target_group.lb_http_tgs : tg.name]
}

output "lb_http_tgs_ports" {
  description = "List of HTTP Target Groups ports"
  value       = [for tg in aws_lb_target_group.lb_http_tgs : tostring(tg.port)]
}

output "lb_http_tgs_map_arn_port" {
  value = zipmap(
    [for tg in aws_lb_target_group.lb_http_tgs : tg.arn],
    [for tg in aws_lb_target_group.lb_http_tgs : tostring(tg.port)]
  )
}

output "lb_https_tgs_ids" {
  description = "List of HTTPS Target Groups IDs"
  value       = [for tg in aws_lb_target_group.lb_https_tgs : tg.id]
}

output "lb_https_tgs_arns" {
  description = "List of HTTPS Target Groups ARNs"
  value       = [for tg in aws_lb_target_group.lb_https_tgs : tg.arn]
}

output "lb_https_tgs_names" {
  description = "List of HTTPS Target Groups Names"
  value       = [for tg in aws_lb_target_group.lb_https_tgs : tg.name]
}

output "lb_https_tgs_ports" {
  description = "List of HTTPS Target Groups ports"
  value       = [for tg in aws_lb_target_group.lb_https_tgs : tostring(tg.port)]
}

output "lb_https_tgs_map_arn_port" {
  value = zipmap(
    [for tg in aws_lb_target_group.lb_https_tgs : tg.arn],
    [for tg in aws_lb_target_group.lb_https_tgs : tostring(tg.port)]
  )
}

#------------------------------------------------------------------------------
# AWS LOAD BALANCER - Listeners
#------------------------------------------------------------------------------
output "lb_http_listeners_ids" {
  description = "List of HTTP Listeners IDs"
  value       = [for listener in aws_lb_listener.lb_http_listeners : listener.id]
}

output "lb_http_listeners_arns" {
  description = "List of HTTP Listeners ARNs"
  value       = [for listener in aws_lb_listener.lb_http_listeners : listener.arn]
}

output "lb_https_listeners_ids" {
  description = "List of HTTPS Listeners IDs"
  value       = [for listener in aws_lb_listener.lb_https_listeners : listener.id]
}

output "lb_https_listeners_arns" {
  description = "List of HTTPS Listeners ARNs"
  value       = [for listener in aws_lb_listener.lb_https_listeners : listener.arn]
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