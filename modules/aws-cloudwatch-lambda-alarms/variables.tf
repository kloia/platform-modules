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
