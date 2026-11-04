variable "analyzer_name" {
  description = "Name of the analyzer. Unique per account and Region."
  type        = string
}

variable "type" {
  description = "ACCOUNT, or ORGANIZATION from the management account or a delegated administrator. ORGANIZATION needs IAM Access Analyzer trusted access in AWS Organizations."
  type        = string
  default     = "ACCOUNT"

  validation {
    condition     = contains(["ACCOUNT", "ORGANIZATION"], var.type)
    error_message = "type must be ACCOUNT or ORGANIZATION."
  }
}

variable "archive_rules" {
  description = <<-EOT
    Archive rules for expected findings, keyed by rule name. Each rule is a list
    of filters; a finding is archived when it matches all of them. A filter sets
    `criteria` (for example `principal.AWS`, `resourceType`, `isPublic`) and one
    of `eq`, `neq`, `contains` or `exists`.
  EOT
  type = map(list(object({
    criteria = string
    eq       = optional(list(string))
    neq      = optional(list(string))
    contains = optional(list(string))
    exists   = optional(bool)
  })))
  default = {}
}

variable "tags" {
  description = "Tags for the analyzer."
  type        = map(string)
  default     = {}
}
