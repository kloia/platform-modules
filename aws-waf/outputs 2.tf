output "web_acl_arn" {
  description = "ARN of the Waf WebACL"
  value = aws_wafv2_web_acl.waf_acl[0].arn
}

output "web_acl_capacity" {
  description = "Web ACL capacity units (WCUs) currently being used by this web ACL"
  value = aws_wafv2_web_acl.waf_acl[0].capacity
}