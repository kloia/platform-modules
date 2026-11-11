variable "project_name" {
  type        = string
  description = "Atlas project name, looked up by name, so the caller needs no dependency on the unit that creates the project."
}

variable "tiers" {
  type = map(object({
    severity = optional(string)
    targets = list(object({
      type          = string
      channel_name  = optional(string)
      email_address = optional(string)
      roles         = optional(list(string))
    }))
  }))
  description = "Where each tier's alerts are sent. severity becomes the alerts' severity_override (INFO, WARNING, ERROR, CRITICAL). Target types: OPS_GENIE (uses var.opsgenie), WEBHOOK (uses var.webhook), SLACK (channel_name, uses the project's Slack integration), EMAIL (email_address), GROUP (roles). The default alerts use the tiers critical and warning."

  validation {
    condition = alltrue(flatten([for t in values(var.tiers) : [
      for x in t.targets : contains(["OPS_GENIE", "WEBHOOK", "SLACK", "EMAIL", "GROUP"], x.type)
    ]]))
    error_message = "Target type must be OPS_GENIE, WEBHOOK, SLACK, EMAIL or GROUP."
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

variable "opsgenie" {
  type = object({
    api_key_ssm_path         = optional(string)
    region                   = optional(string, "US")
    use_existing_integration = optional(bool, false)
  })
  default     = null
  description = "The project's Opsgenie integration, used by every OPS_GENIE target. By default the module manages it with the key from the SSM SecureString api_key_ssm_path. use_existing_integration = true references the project's existing integration instead and sends no key."

  validation {
    condition     = var.opsgenie == null || try(var.opsgenie.use_existing_integration, false) || try(var.opsgenie.api_key_ssm_path, null) != null
    error_message = "opsgenie.api_key_ssm_path is required unless use_existing_integration is true."
  }

  validation {
    condition     = var.opsgenie == null || contains(["US", "EU"], try(var.opsgenie.region, "US"))
    error_message = "opsgenie.region must be US or EU."
  }
}

variable "webhook" {
  type = object({
    url_ssm_path             = optional(string)
    format                   = optional(string)
    body_template            = optional(string)
    use_existing_integration = optional(bool, false)
  })
  default     = null
  description = "The project's webhook integration, used by every WEBHOOK target. By default the module manages it with the URL from the SSM SecureString url_ssm_path. use_existing_integration = true references the project's existing integration instead and sends no URL. format = \"SLACK\" sends a Slack incoming-webhook message; body_template, if set, replaces it with a custom JSON body using $${field} placeholders. With neither, Atlas sends its own payload, which a Slack incoming webhook rejects."

  validation {
    condition     = var.webhook == null || try(var.webhook.use_existing_integration, false) || try(var.webhook.url_ssm_path, null) != null
    error_message = "webhook.url_ssm_path is required unless use_existing_integration is true."
  }

  validation {
    condition     = try(var.webhook.format, null) == null || try(var.webhook.format, null) == "SLACK"
    error_message = "webhook.format must be SLACK or unset."
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
    title       = optional(string)
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
