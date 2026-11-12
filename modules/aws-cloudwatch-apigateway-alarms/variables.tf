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
    anomaly_alarm        = optional(bool)
    anomaly_band_width   = optional(number)
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

variable "enable_anomaly_alarm" {
  description = <<-EOT
    Also create, for every API, an alarm on a rise of the 5XX rate above the range CloudWatch expects (anomaly
    detection). It suits APIs with a steady, known 5XX rate, where no fixed threshold fits; an API may turn it
    on or off with `anomaly_alarm`. The fixed-threshold alarm is kept. CloudWatch takes up to two weeks to learn
    the range, and bills the alarm for the metrics it reads plus the upper and lower band.
  EOT
  type        = bool
  default     = false
}

variable "anomaly_band_width" {
  description = "Width of the expected range for the anomaly alarm, in standard deviations. A larger value tolerates more deviation before alarming."
  type        = number
  default     = 3

  validation {
    condition     = var.anomaly_band_width > 0
    error_message = "anomaly_band_width must be above 0."
  }
}
