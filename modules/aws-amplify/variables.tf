variable "name" {
  description = "Application repository address connect to"
  type        = string
}

variable "repository" {
  description = "Application repository address connect to"
  type        = string
}

variable "build_spec" {
  description = "Application repository address connect to"
  type        = string
}

variable "environment_variables" {
  type    = any
  default = {}
}

variable "enable_auto_branch_creation" {
  description = "Application repository address connect to"
  type        = bool
  default     = false
}

variable "enable_basic_auth" {
  description = "Application repository address connect to"
  type        = bool
  default     = false
}

variable "enable_branch_auto_build" {
  description = "Application repository address connect to"
  type        = bool
  default     = false
}

variable "enable_branch_auto_deletion" {
  description = "Application repository address connect to"
  type        = bool
  default     = false
}

variable "enable_auto_build" {
  description = "Application repository address connect to"
  type        = bool
  default     = true
}

variable "enable_performance_mode" {
  description = "Application repository address connect to"
  type        = bool
  default     = false
}

variable "platform" {
  description = "Application repository address connect to"
  type        = string
  default     = "WEB_COMPUTE"
}

variable "auto_branch_creation_patterns" {
  description = "Application repository address connect to"
  type        = list(any)
  default     = []
}

variable "iam_service_role_arn" {
  description = "Application repository address connect to"
  type        = string
}

variable "custom_rules" {
  type    = list(any)
  default = []
}

variable "tags" {
  type    = any
  default = []
}

variable "branch_name" {
  type    = string
  default = "main"
}

variable "framework" {
  type = string
}
variable "domain_name" {
  type = string
}
variable "sub_domains" {
  type = list(any)
}

variable "stage" {
  type = string
}

variable "enable_pull_request_preview" {
  type    = bool
  default = false
}

variable "enable_auto_sub_domain" {
  type    = bool
  default = false
}
