##################################################
# Security Hub
##################################################
variable "enable_default_standards" {
  description = "Whether to enable the security standards that Security Hub has designated as automatically enabled including: AWS Foundational Security Best Practices v1.0.0 and CIS AWS Foundations Benchmark v1.2.0. Defaults to `true`."
  type        = bool
  default     = true
}

variable "control_finding_generator" {
  description = "Updates whether the calling account has consolidated control findings turned on. If the value for this field is set to SECURITY_CONTROL, Security Hub generates a single finding for a control check even when the check applies to multiple enabled standards. If the value for this field is set to STANDARD_CONTROL, Security Hub generates separate findings for a control check when the check applies to multiple enabled standards. For accounts that are part of an organization, this value can only be updated in the administrator account."
  type        = string
  default     = "STANDARD_CONTROL"
}

variable "linking_mode" {
  description = "Indicates whether to aggregate findings from all of the available Regions or from a specified list. The options are ALL_REGIONS, ALL_REGIONS_EXCEPT_SPECIFIED or SPECIFIED_REGIONS. When ALL_REGIONS or ALL_REGIONS_EXCEPT_SPECIFIED are used, Security Hub will automatically aggregate findings from new Regions as Security Hub supports them and you opt into them."
  type        = string
  default     = "ALL_REGIONS"
}

variable "auto_enable_controls" {
  description = "Whether to automatically enable new controls when they are added to standards that are enabled. By default, this is set to true, and new controls are enabled automatically. To not automatically enable new controls, set this to false."
  type        = bool
  default     = true
}

variable "specified_regions" {
  description = "List of regions to include or exclude (required if linking_mode is set to ALL_REGIONS_EXCEPT_SPECIFIED or SPECIFIED_REGIONS)"
  type        = list(string)
  default     = null
}

##################################################
# Security Hub Subscriptions
##################################################
variable "standards_config" {
  description = <<EOF
  `aws_foundational_security_best_practices` - AWS Foundational Security Best Practices
  `cis_aws_foundations_benchmark_v120` - CIS AWS Foundations Benchmark v1.2.0
  `cis_aws_foundations_benchmark_v140` - CIS AWS Foundations Benchmark v1.4.0
  `nist_sp_800_53_rev5` - NIST SP 800-53 Rev. 5
  `pci_dss` - PCI DSS
  EOF
  type = object({
    aws_foundational_security_best_practices = object({
      enable          = bool
      status          = optional(string)
      disabled_reason = optional(string)
    })
    cis_aws_foundations_benchmark_v120 = object({
      enable          = bool
      status          = optional(string)
      disabled_reason = optional(string)
    })
    cis_aws_foundations_benchmark_v140 = object({
      enable          = bool
      status          = optional(string)
      disabled_reason = optional(string)
    })
    nist_sp_800_53_rev5 = object({
      enable          = bool
      status          = optional(string)
      disabled_reason = optional(string)
    })
    pci_dss = object({
      enable          = bool
      status          = optional(string)
      disabled_reason = optional(string)
    })
  })
  default = {
    aws_foundational_security_best_practices = {
      enable = true
      status = "ENABLED"
    }
    cis_aws_foundations_benchmark_v120 = {
      enable = true
      status = "ENABLED"
    }
    cis_aws_foundations_benchmark_v140 = {
      enable = false
    }
    nist_sp_800_53_rev5 = {
      enable = false
    }
    pci_dss = {
      enable = false
    }
  }
}

variable "product_config" {
  description = "The ARN of the product that generates findings that you want to import into Security Hub."
  type = list(object({
    enable = bool
    arn    = string
  }))
  default = null
}

##################################################
# Security Hub Action Targets
##################################################
variable "action_target" {
  description = <<EOF
  Creates Security Hub custom action.
  `name`        - The description for the custom action target.
  `identifier`  - The ID for the custom action target.
  `description` - The name of the custom action target.
  EOF
  type = list(object({
    name        = string
    identifier  = string
    description = string
  }))
  default = []
}

##################################################
# Security Hub Delegated Admin
##################################################
variable "admin_account_id" {
  description = "AWS Organizations Admin Account Id. Defaults to `null`"
  type        = string
  default     = null
}

variable "auto_enable_standards" {
  description = "Automatically enable Security Hub default standards for new member accounts in the organization. To opt-out of enabling default standards, set to `NONE`. Defaults to `DEFAULT`."
  type        = string
  default     = "NONE"
}

##################################################
# Security Hub Account Member
##################################################
variable "member_config" {
  description = <<EOF
  Specifies the member account configuration:
  `account_id`                 - The 13 digit ID number of the member account. Example: `123456789012`.
  `email`                      - Email address to send the invite for member account. Defaults to `null`.
  `invite`                     - Whether to invite the account to SecurityHub as a member. Defaults to `false`. To detect if an invitation needs to be (re-)sent, the Terraform state value is true based on a `member_status` of `Disabled` | `Enabled` |  `Invited` |  EmailVerificationInProgress.
  EOF
  type = list(object({
    account_id = number
    email      = string
    invite     = bool
  }))
  default = null
}