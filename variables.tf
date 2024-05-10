variable "name_resource_arn_map" {
  type        = any
  description = "A map of names and ARNs of resources to be protected. The name will be used as the name of the resource in the AWS console."
  default     = {}
}

variable "tags" {
  type        = map(string)
  description = "A map of tag names and values for tags to apply to all taggable resources created by the module. Default value is a blank map to allow for using Default Tags in the provider."
  default     = {}
}