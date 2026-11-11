variable "project_name" {
  type        = string
  description = "Atlas project name, looked up by name, so the caller needs no dependency on the unit that creates the project."
}

variable "tiers" {
  type = map(object({
    severity = optional(string)
    targets = list(object({
      type             = string
      api_key_ssm_path = optional(string)
      region           = optional(string, "US")
      channel_name     = optional(string)
      email_address    = optional(string)
      roles            = optional(list(string))
    }))
  }))
  description = "Where each tier's alerts are sent. severity becomes the alerts' severity_override (INFO, WARNING, ERROR, CRITICAL). Target types: OPS_GENIE (api_key_ssm_path, region), SLACK (channel_name, uses the project's Slack integration), EMAIL (email_address), GROUP (roles). The default alerts use the tiers critical and warning."

  validation {
    condition = alltrue(flatten([for t in values(var.tiers) : [
      for x in t.targets : contains(["OPS_GENIE", "SLACK", "EMAIL", "GROUP"], x.type)
    ]]))
    error_message = "Target type must be OPS_GENIE, SLACK, EMAIL or GROUP."
  }

  validation {
    condition = alltrue(flatten([for t in values(var.tiers) : [
      for x in t.targets : x.type != "OPS_GENIE" || x.api_key_ssm_path != null
    ]]))
    error_message = "An OPS_GENIE target needs api_key_ssm_path."
  }

  validation {
    condition = alltrue(flatten([for t in values(var.tiers) : [
      for x in t.targets : x.type != "SLACK" || x.channel_name != null
    ]]))
    error_message = "A SLACK target needs channel_name."
  }

  validation {
    condition     = alltrue([for t in values(var.tiers) : t.severity == null || contains(["INFO", "WARNING", "ERROR", "CRITICAL"], t.severity)])
    error_message = "Tier severity must be INFO, WARNING, ERROR or CRITICAL."
  }
}

variable "enable_default_alerts" {
  type        = bool
  default     = true
  description = "Create the default alert set (see README). Set false to create only the entries in alerts."
}

variable "alerts" {
  type = map(object({
    event_type  = string
    tier        = string
    description = optional(string)
    enabled     = optional(bool, true)
    delay_min   = optional(number, 0)
    metric_threshold = optional(object({
      metric_name = string
      operator    = string
      threshold   = number
      units       = optional(string, "RAW")
      mode        = optional(string, "AVERAGE")
    }))
    threshold = optional(object({
      operator  = string
      threshold = number
      units     = optional(string)
    }))
    matchers = optional(list(object({
      field_name = string
      operator   = string
      value      = string
    })), [])
  }))
  default     = {}
  description = "Alerts added to the default set, keyed by a stable name. A key that matches a default replaces it entirely. description is for the code and docs only; Atlas has no field for it."

  validation {
    condition     = alltrue([for a in values(var.alerts) : !(a.metric_threshold != null && a.threshold != null)])
    error_message = "Set metric_threshold or threshold on an alert, not both."
  }
}
