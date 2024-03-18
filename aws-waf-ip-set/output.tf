output "blacklist_ip_set_arn" {
  value       = aws_wafv2_ip_set.blacklist_ip_set.arn
  description = "arn of blacklist ip set"
}

output "whitelist_ip_set_arn" {
  value       = aws_wafv2_ip_set.whitelist_ip_set.arn
  description = "arn of whitelist ip set"
}

output "dynamic_waf_ip_set_arns" {
  value       = { for key, ip_set in aws_wafv2_ip_set.ip_addresses : key => ip_set.arn }
  description = "Map of ARNs for dynamically created IP address groups"
}

