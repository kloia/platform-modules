variable "name_prefix" {
  type        = string
  description = "Prefix for role, inline policy and statement names. Roles are named <prefix>Plan<account_class>Role and <prefix>Apply<account_class>Role, so changing it renames (replaces) existing roles."

  validation {
    condition     = can(regex("^[A-Za-z0-9]+$", var.name_prefix))
    error_message = "name_prefix must be alphanumeric (it is used inside IAM statement Sids)."
  }
}

variable "account_class" {
  type        = string
  description = "Tier this role pair serves, NonProd or Prod. Selects the role-name suffix."

  validation {
    condition     = contains(["NonProd", "Prod"], var.account_class)
    error_message = "account_class must be one of: NonProd, Prod."
  }
}

variable "github_organization" {
  type        = string
  description = "GitHub organization that owns the infrastructure repositories."
}

variable "plan_repositories" {
  type        = list(string)
  description = "Bare repository names allowed to assume the plan role (pull_request and default-branch ref subjects)."

  validation {
    condition     = length(var.plan_repositories) > 0
    error_message = "plan_repositories must enumerate at least one repository."
  }

  validation {
    condition     = alltrue([for repo in var.plan_repositories : can(regex("^[A-Za-z0-9._-]+$", repo)) && !strcontains(repo, "..")])
    error_message = "plan_repositories must be bare repository names; '*', '?', '/', '..', empty and whitespace are rejected so a subject can never become a wildcard."
  }
}

variable "plan_workflow_dispatch_ref" {
  type        = string
  description = "Exact default-branch ref trusted for the plan role's ref subject."
  default     = "refs/heads/main"

  validation {
    condition     = can(regex("^refs/heads/[A-Za-z0-9._/-]+$", var.plan_workflow_dispatch_ref)) && !strcontains(var.plan_workflow_dispatch_ref, "..")
    error_message = "plan_workflow_dispatch_ref must be an exact refs/heads/<branch> with no wildcard and no '..'."
  }
}

variable "apply_repositories" {
  type        = list(string)
  description = "Bare repository names allowed to assume the apply role from a protected GitHub Environment."

  validation {
    condition     = length(var.apply_repositories) > 0
    error_message = "apply_repositories must enumerate at least one repository."
  }

  validation {
    condition     = alltrue([for repo in var.apply_repositories : can(regex("^[A-Za-z0-9._-]+$", repo)) && !strcontains(repo, "..")])
    error_message = "apply_repositories must be bare repository names; '*', '?', '/', '..', empty and whitespace are rejected so a subject can never become a wildcard."
  }
}

variable "apply_environments" {
  type        = list(string)
  description = "Protected GitHub Environment names that gate the apply role's subject."

  validation {
    condition     = length(var.apply_environments) > 0
    error_message = "apply_environments must enumerate at least one protected environment."
  }

  validation {
    condition     = alltrue([for env in var.apply_environments : env != "" && !strcontains(env, "*") && !strcontains(env, "?") && !strcontains(env, "..")])
    error_message = "apply_environments must be exact environment names; '*', '?', '..' and empty values are rejected."
  }
}

variable "github_oidc_provider_arn" {
  type        = string
  description = "ARN of the existing token.actions.githubusercontent.com OIDC provider in this account."
}

variable "target_plan_role_name" {
  type        = string
  description = "Name every target plan role ARN must end with."
}

variable "target_apply_role_name" {
  type        = string
  description = "Name every target apply role ARN must end with."
}

variable "target_plan_role_arns" {
  type        = list(string)
  description = "Target-account plan role ARNs the plan role may assume. Each must end in :role/<target_plan_role_name>."

  validation {
    condition     = alltrue([for arn in var.target_plan_role_arns : endswith(arn, ":role/${var.target_plan_role_name}")])
    error_message = "target_plan_role_arns may only contain ARNs ending in :role/<target_plan_role_name>."
  }
}

variable "target_apply_role_arns" {
  type        = list(string)
  description = "Target-account apply role ARNs the apply role may assume. Each must end in :role/<target_apply_role_name>."

  validation {
    condition     = alltrue([for arn in var.target_apply_role_arns : endswith(arn, ":role/${var.target_apply_role_name}")])
    error_message = "target_apply_role_arns may only contain ARNs ending in :role/<target_apply_role_name>."
  }
}

variable "max_session_duration" {
  type        = number
  description = "Maximum session in seconds for both roles. The pipeline's apply session setting must not exceed it."
  default     = 3600

  validation {
    condition     = var.max_session_duration >= 3600 && var.max_session_duration <= 43200
    error_message = "max_session_duration must be between 3600 and 43200 seconds."
  }
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to both roles."
  default     = {}
}
