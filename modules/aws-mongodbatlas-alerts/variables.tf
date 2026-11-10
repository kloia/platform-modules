variable "project_name" {
  type        = string
  description = "Atlas project name, looked up by name, so the caller needs no dependency on the unit that creates the project."
}

variable "create_opsgenie_integration" {
  type        = bool
  default     = true
  description = "Create the project's Opsgenie integration. Atlas allows one Opsgenie integration per project: set false when the project already has one, and the module routes its alerts to that integration."
}

variable "opsgenie_api_key" {
  type        = string
  default     = null
  sensitive   = true
  description = "API key of the Opsgenie integration that receives the alerts. Required when create_opsgenie_integration is true. Opsgenie sets the alert priority from this integration; Atlas sends none."
}

variable "opsgenie_region" {
  type        = string
  description = "Opsgenie region of the integration: US or EU."

  validation {
    condition     = contains(["US", "EU"], var.opsgenie_region)
    error_message = "opsgenie_region must be US or EU."
  }
}

variable "enable_default_alerts" {
  type        = bool
  default     = true
  description = "Create the default critical alert set (see README). Set false to create only the entries in alerts."
}

variable "alerts" {
  type = map(object({
    event_type = string
    enabled    = optional(bool, true)
    delay_min  = optional(number, 0)
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
  description = "Alerts to add to the default set, keyed by a stable name. An entry with the key of a default alert replaces that default entirely. Use metric_threshold for OUTSIDE_METRIC_THRESHOLD events and threshold for events with their own threshold (for example REPLICATION_OPLOG_WINDOW_RUNNING_OUT)."

  validation {
    condition     = alltrue([for a in values(var.alerts) : !(a.metric_threshold != null && a.threshold != null)])
    error_message = "Set metric_threshold or threshold on an alert, not both."
  }
}
