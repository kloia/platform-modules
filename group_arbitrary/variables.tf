variable "tags" {
  type        = map(string)
  description = "Key-value map of resource tags. If configured with a provider default_tags configuration block present, tags with matching keys will overwrite those defined at the provider-level."
  default     = {}
}

variable "group_id" {
  type        = string
  description = "The name of the protection group."
  default     = "aws_shield_all"
}

variable "aggregation" {
  type        = string
  description = "Defines how AWS Shield combines resource data for the group in order to detect, mitigate, and report events."
  default     = "SUM"
  validation {
    condition = contains([
      "SUM",
      "MEAN",
      "MAX",
    ], var.aggregation)
    error_message = "Valid values are limited to (SUM,MEAN,MAX)."
  }
}

variable "members" {
  type        = list(string)
  description = "The Amazon Resource Names (ARNs) of the resources to include in the protection group. You must set this when you set pattern to ARBITRARY and you must not set it for any other pattern setting."
}