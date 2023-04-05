variable "ip_set_addresses" {
    description = "IP addresses"
    type = list(string)
    default = []
}

variable "ip_set_name" {
    description = "IP Set Name"
    default = ""
}

variable "create_waf" {
    description = "condition to create"
    default = true
}

variable "waf_rule_name" {
    description = "Name of the WAF rule"
    default = ""
}

variable "waf_web_acl_name" {
    description = "Name of the WAF ACL"
    default = ""
}

variable "description" {
    description = "Description of the IP set"
    default = ""
  
}

variable "ip_set_description" {
    description = "Description of the IP set"
    default = ""
  
}

variable "metric_name" {
    description = "A friendly name of the CloudWatch metric."
    default = ""
  
}

variable "cw_metrics" {
    description = "CW metrics"
    default = false
}