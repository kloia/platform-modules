variable "name_prefix" {
  description = "Prefix of every alarm name, e.g. `<team>-<env>`."
  type        = string
}

variable "functions" {
  description = <<-EOT
    Lambda functions to alarm on, keyed by function name. A name that matches no function fails the plan.
    Each value overrides the module-wide default of the same name for that function only; an omitted
    field uses the default. Use `{}` for a function that needs no override.
  EOT
  type = map(object({
    error_rate_threshold        = optional(number)
    min_invocations             = optional(number)
    throttle_threshold          = optional(number)
    duration_percent_of_timeout = optional(number)
    priority                    = optional(string)
    anomaly_alarm               = optional(bool)
    anomaly_band_width          = optional(number)
    anomaly_priority            = optional(string)
  }))

  validation {
    condition = alltrue([
      for f in var.functions :
      f.error_rate_threshold == null ? true : (f.error_rate_threshold >= 0 && f.error_rate_threshold <= 100)
    ])
    error_message = "error_rate_threshold must be between 0 and 100 (a percentage)."
  }

  validation {
    condition = alltrue([
      for f in var.functions :
      f.priority == null ? true : contains(["P1", "P2", "P3", "P4", "P5"], f.priority)
    ])
    error_message = "priority must be one of P1, P2, P3, P4, P5."
  }

  validation {
    condition = alltrue([
      for f in var.functions :
      f.anomaly_priority == null ? true : contains(["P1", "P2", "P3", "P4", "P5"], f.anomaly_priority)
    ])
    error_message = "anomaly_priority must be one of P1, P2, P3, P4, P5."
  }

  validation {
    condition = alltrue([
      for f in var.functions :
      f.duration_percent_of_timeout == null ? true : (f.duration_percent_of_timeout > 0 && f.duration_percent_of_timeout <= 100)
    ])
    error_message = "duration_percent_of_timeout must be above 0 and at most 100."
  }
}

variable "error_rate_threshold" {
  description = "Alarm when failed invocations exceed this percentage of invocations."
  type        = number
  default     = 5
}

variable "min_invocations" {
  description = "Invocations per period below which the error rate is treated as 0, so one failure on idle traffic does not alarm."
  type        = number
  default     = 20
}

variable "throttle_threshold" {
  description = "Alarm when throttled invocations in one period reach this count."
  type        = number
  default     = 1
}

variable "duration_percent_of_timeout" {
  description = "Alarm when p99 duration exceeds this percentage of the function's configured timeout, read from the function itself."
  type        = number
  default     = 80
}

variable "enable_throttle_alarm" {
  description = "Create the throttle alarm for every function."
  type        = bool
  default     = true
}

variable "enable_duration_alarm" {
  description = "Create the duration alarm for every function."
  type        = bool
  default     = true
}

variable "priority" {
  description = <<-EOT
    Opsgenie priority, P1 to P5, written at the start of every alarm description as `[P2]`. An Opsgenie
    CloudWatch integration can read it from the description; leave it null when the integration has no such
    rule, and the description stays unchanged. A function may override it.
  EOT
  type        = string
  default     = null

  validation {
    condition     = var.priority == null ? true : contains(["P1", "P2", "P3", "P4", "P5"], var.priority)
    error_message = "priority must be one of P1, P2, P3, P4, P5."
  }
}

variable "period" {
  description = "Metric period in seconds."
  type        = number
  default     = 300
}

variable "evaluation_periods" {
  description = "Periods evaluated by the error-rate and duration alarms. The throttle alarm always evaluates one."
  type        = number
  default     = 3
}

variable "datapoints_to_alarm" {
  description = "Breaching periods, out of evaluation_periods, that trigger the error-rate and duration alarms."
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
    Also create, for every function, an alarm on a rise of the error rate above the range CloudWatch expects
    (anomaly detection). It suits functions with a steady, known error rate, where no fixed threshold fits;
    a function may turn it on or off with `anomaly_alarm`. The fixed-threshold alarm is kept. CloudWatch takes up
    to two weeks to learn the range, and bills the alarm for the metrics it reads plus the upper and lower band.
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

variable "anomaly_priority" {
  description = <<-EOT
    Opsgenie priority of the anomaly alarm, written like `priority`. Null uses the function's `priority`. Set it lower
    than `priority` while the model is still learning, so a fixed-threshold alarm keeps its priority and the
    anomaly alarm does not page.
  EOT
  type        = string
  default     = null

  validation {
    condition     = var.anomaly_priority == null ? true : contains(["P1", "P2", "P3", "P4", "P5"], var.anomaly_priority)
    error_message = "anomaly_priority must be one of P1, P2, P3, P4, P5."
  }
}
