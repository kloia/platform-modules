variable "users" {
  description = "Identity Center users to create, keyed by user name (for example jane.doe). display_name defaults to \"<given_name> <family_name>\"."
  type = map(object({
    given_name   = string
    family_name  = string
    display_name = optional(string)
    email        = string
    # Optional email attributes, so an imported user whose email has a type or is not primary matches live.
    email_type    = optional(string)
    email_primary = optional(bool, true)
  }))
  default = {}
}

variable "groups" {
  description = "Identity Center groups to create, keyed by group display name. members lists user names, which may be users created by this call (users) or looked up (existing_users)."
  type = map(object({
    description = optional(string)
    members     = optional(list(string), [])
  }))
  default = {}
}

variable "permission_sets" {
  description = "Permission sets to create, keyed by permission set name. inline_policy is a JSON string and is normalised with jsonencode(jsondecode()). permissions_boundary takes either managed_policy_arn or customer_managed_policy."
  type = map(object({
    description         = optional(string)
    session_duration    = optional(string, "PT1H")
    relay_state         = optional(string)
    managed_policy_arns = optional(list(string), [])
    customer_managed_policies = optional(list(object({
      name = string
      path = optional(string, "/")
    })), [])
    inline_policy = optional(string)
    permissions_boundary = optional(object({
      managed_policy_arn = optional(string)
      customer_managed_policy = optional(object({
        name = string
        path = optional(string, "/")
      }))
    }))
    tags = optional(map(string), {})
  }))
  default = {}

  validation {
    condition     = alltrue([for k, v in var.permission_sets : can(regex("^PT([0-9]+H)?([0-9]+M)?$", v.session_duration)) && v.session_duration != "PT"])
    error_message = "session_duration must be an ISO-8601 duration of hours and minutes, for example PT1H or PT8H30M."
  }

  validation {
    condition     = alltrue([for k, v in var.permission_sets : v.inline_policy == null || can(jsondecode(v.inline_policy))])
    error_message = "inline_policy must be a valid JSON string."
  }
}

variable "account_assignments" {
  description = "Account assignments. principal_name is a group display name (GROUP) or a user name (USER); permission_set_name and the principal may come from this call or from the existing_* lookups. One assignment is created per entry of account_ids."
  type = list(object({
    principal_type      = string
    principal_name      = string
    permission_set_name = string
    account_ids         = list(string)
  }))
  default = []

  validation {
    condition     = alltrue([for a in var.account_assignments : contains(["GROUP", "USER"], a.principal_type)])
    error_message = "principal_type must be GROUP or USER."
  }
}

variable "existing_users" {
  description = "User names to look up in the identity store (users owned by another unit, an external IdP or AWS Control Tower)."
  type        = list(string)
  default     = []
}

variable "existing_groups" {
  description = "Group display names to look up in the identity store (groups owned by another unit, an external IdP or AWS Control Tower)."
  type        = list(string)
  default     = []
}

variable "existing_permission_sets" {
  description = "Permission set names to look up (permission sets owned by another unit or by AWS Control Tower)."
  type        = list(string)
  default     = []
}
