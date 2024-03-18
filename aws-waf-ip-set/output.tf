output "blacklist_ip_set_arn" {
  value       = aws_wafv2_ip_set.blacklist_ip_set.arn
  description = "arn of blacklist ip set"
}

output "whitelist_ip_set_arn" {
  value       = aws_wafv2_ip_set.whitelist_ip_set.arn
  description = "arn of whitelist ip set"
}

output "dynamic_waf_ip_set_arn" {

  value       = aws_wafv2_ip_set.ip_addresses.arn
  description = "arns of dynamically created ip address groups"
}

