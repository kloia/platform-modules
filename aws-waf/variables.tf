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


variable "metric_name" {
    description = "A friendly name of the CloudWatch metric."
    default = ""
  
}

variable "cw_metrics" {
    description = "CW metrics"
    default = false
}

variable "enabled" {
  type        = bool
  description = "Whether to create the resources. Set to `false` to prevent the module from creating any resources"
  default     = true
}


variable "tags" {
  description = "A map of tags (key-value pairs) passed to resources."
  type        = map(string)
  default     = {}
}

variable "rules" {
  description = "List of WAF rules."
  type        = any
  default     = []
}

variable "visibility_config" {
  description = "Visibility config for WAFv2 web acl. https://www.terraform.io/docs/providers/aws/r/wafv2_web_acl.html#visibility-configuration"
  type        = map(string)
  default     = {}
}

variable "create_logging_configuration" {
  type        = bool
  description = "Whether to create logging configuration in order start logging from a WAFv2 Web ACL to Amazon Kinesis Data Firehose."
  default     = false
}

variable "log_destination_configs" {
  type        = list(string)
  description = "The Amazon Kinesis Data Firehose Amazon Resource Name (ARNs) that you want to associate with the web ACL. Currently, only 1 ARN is supported."
  default     = []
}

variable "redacted_fields" {
  description = "The parts of the request that you want to keep out of the logs. Up to 100 `redacted_fields` blocks are supported."
  type        = any
  default     = []
}

variable "allow_default_action" {
  type        = bool
  description = "Set to `true` for WAF to allow requests by default. Set to `false` for WAF to block requests by default."
  default     = true
}

variable "scope" {
  type        = string
  description = "Specifies whether this is for an AWS CloudFront distribution or for a regional application. Valid values are CLOUDFRONT or REGIONAL. To work with CloudFront, you must also specify the region us-east-1 (N. Virginia) on the AWS provider."
  default     = "REGIONAL"
}

variable "logging_filter" {
  type        = any
  description = "A configuration block that specifies which web requests are kept in the logs and which are dropped. You can filter on the rule action and on the web request labels that were applied by matching rules during web ACL evaluation."
  default     = {}
}



variable "custom_response_bodies" {
  type = list(object({
    key          = string
    content      = string
    content_type = string
  }))
  description = "Custom response bodies to be referenced on a per rule basis. https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_web_acl#custom-response-body"
  default     = []
}