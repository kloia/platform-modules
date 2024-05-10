variable "tags" {
  type        = map(string)
  description = "Key-value map of resource tags. If configured with a provider default_tags configuration block present, tags with matching keys will overwrite those defined at the provider-level."
  default     = {}
}

variable "resource_type_protection_group" {
  type = list(object({
    group_id      = string
    aggregation   = string
    members       = list(string)
    resource_type = string
  }))
  validation {
    condition = contains([
      "CLOUDFRONT_DISTRIBUTION",
      "ROUTE_53_HOSTED_ZONE",
      "GLOBAL_ACCELERATOR",
      "APPLICATION_LOAD_BALANCER",
      "CLASSIC_LOAD_BALANCER",
      "ELASTIC_IP_ALLOCATION",
    ], var.resource_type)
    error_message = "Valid values are limited in validation section."
  }
  description = "all shield protection group values list as resource type"
}
