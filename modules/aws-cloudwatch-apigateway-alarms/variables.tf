variable "name_prefix" {
  description = "Prefix of every alarm name, e.g. `<team>-<env>`."
  type        = string
}

variable "apis" {
  description = <<-EOT
    REST APIs to alarm on, keyed by API name (the `ApiName` dimension, which covers every stage).
    Each value overrides the module-wide default of the same name for that API only; an omitted
    field uses the default. Use `{}` for an API that needs no override.
  EOT
  type = map(object({
    error_rate_threshold = optional(number)
    min_requests         = optional(number)
    priority             = optional(string)
  }))

  validation {
    condition = alltrue([
      for a in var.apis :
      a.error_rate_threshold == null ? true : (a.error_rate_threshold >= 0 && a.error_rate_threshold <= 100)
    ])
    error_message = "error_rate_threshold must be between 0 and 100 (a percentage)."
  }

  validation {
    condition = alltrue([
      for a in var.apis :
      a.priority == null ? true : contains(["P1", "P2", "P3", "P4", "P5"], a.priority)
    ])
    error_message = "priority must be one of P1, P2, P3, P4, P5."
  }
}

variable "priority" {
  description = <<-EOT
    Opsgenie priority, P1 to P5, written at the start of every alarm description as `[P2]`. An Opsgenie
    CloudWatch integration can read it from the description; leave it null when the integration has no such
    rule, and the description stays unchanged. An API may override it.
  EOT
  type        = string
  default     = null

  validation {
    condition     = var.priority == null ? true : contains(["P1", "P2", "P3", "P4", "P5"], var.priority)
    error_message = "priority must be one of P1, P2, P3, P4, P5."
  }
}

variable "error_rate_threshold" {
  description = "Alarm when 5XX responses exceed this percentage of requests."
  type        = number
  default     = 5
}

variable "min_requests" {
  description = "Requests per period below which the rate is treated as 0, so one error on idle traffic does not alarm."
  type        = number
  default     = 20
}

variable "period" {
  description = "Metric period in seconds."
  type        = number
  default     = 300
}

variable "evaluation_periods" {
  description = "Number of periods evaluated."
  type        = number
  default     = 3
}

variable "datapoints_to_alarm" {
  description = "Breaching periods, out of evaluation_periods, that trigger the alarm."
  type        = number
  default     = 3
}

variable "description_suffix" {
  description = "Appended to every alarm description, e.g. where to look next."
  type        = string
  default     = ""
}

variable "alarm_actions" {
  description = "ARNs notified when an alarm fires."
  type        = list(string)
  default     = []
}

variable "ok_actions" {
  description = "ARNs notified when an alarm returns to OK."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags for every alarm."
  type        = map(string)
  default     = {}
}
