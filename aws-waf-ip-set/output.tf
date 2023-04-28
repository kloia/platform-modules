output "blacklist_ip_set_arn" {
    value = aws_wafv2_ip_set.blacklist_ip_set.arn
    description = "arn of blacklist ip set"
}

output "whitelist_ip_set_arn" {
    value = aws_wafv2_ip_set.whitelist_ip_set.arn
    description = "arn of whitelist ip set"
}