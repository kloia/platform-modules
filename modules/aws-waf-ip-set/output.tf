output "blacklist_ip_set_arn" {
  value       = try(aws_wafv2_ip_set.blacklist_ip_set[0].arn, null)
  description = "arn of blacklist ip set, null if create_blacklist = false"
}

output "whitelist_ip_set_arn" {
  value       = try(aws_wafv2_ip_set.whitelist_ip_set[0].arn, null)
  description = "arn of whitelist ip set, null if create_whitelist = false"
}

output "dynamic_waf_ip_set_arns" {
  value       = { for key, ip_set in aws_wafv2_ip_set.ip_addresses : key => ip_set.arn }
  description = "Map of ARNs for dynamically created IP address groups"
}

