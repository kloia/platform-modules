variable "name_prefix" {
  description = "Prefix of every alarm name, e.g. `<team>-<env>`."
  type        = string
}

variable "state_machines" {
  description = <<-EOT
    State machines to alarm on, keyed by name. A name that matches no state machine fails the plan.
    Each value overrides the module-wide default of the same name for that state machine only; an omitted
    field uses the default. Use `{}` for a state machine that needs no override.
  EOT
  type = map(object({
    failed_threshold    = optional(number)
    timed_out_threshold = optional(number)
    throttled_threshold = optional(number)
  }))
}

variable "failed_threshold" {
  description = "Alarm when failed executions in one period reach this count."
  type        = number
  default     = 1
}

variable "timed_out_threshold" {
  description = "Alarm when timed-out executions in one period reach this count."
  type        = number
  default     = 1
}

variable "throttled_threshold" {
  description = "Alarm when throttled state entries and retries in one period reach this count."
  type        = number
  default     = 1
}

variable "enable_throttled_alarm" {
  description = "Create the throttled alarm. ExecutionThrottled is emitted only when throttling happens."
  type        = bool
  default     = true
}

variable "period" {
  description = "Metric period in seconds."
  type        = number
  default     = 300
}

variable "evaluation_periods" {
  description = "Number of periods evaluated."
  type        = number
  default     = 1
}

variable "datapoints_to_alarm" {
  description = "Breaching periods, out of evaluation_periods, that trigger the alarm."
  type        = number
  default     = 1
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
